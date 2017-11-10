using Gda;

public errordomain Icd.DatabaseError {
    EXECUTE_QUERY,
    PARSE
}

/**
 * FIXME Maybe... Don't pull config into this class, use Parameters[] instead (?)
 */
public class Icd.Database : GLib.Object {

    public Connection conn { get; construct set; }

    public Database () {
        var config = Icd.Config.get_default ();

        /* Establish database connection */
        try {
            var dsn = config.get_db_dsn ();
            if (dsn != null) {
                conn = Gda.Connection.open_from_dsn (dsn, null,
                            Gda.ConnectionOptions.THREAD_SAFE);
            } else {
                string cnc = "";
                var provider = config.get_db_provider ();
                switch (config.get_db_provider ()) {
                    case "MySQL":
                        cnc = "DB_NAME=%s;HOST=%s;PORT=%d".printf (
                                    config.get_db_name (),
                                    config.get_db_host (),
                                    config.get_db_port ());
                        break;
                    case "PostgreSQL":
                        cnc = "DB_NAME=%s;HOST=%s;PORT=%d".printf (
                                    config.get_db_name (),
                                    config.get_db_host (),
                                    config.get_db_port ());
                        break;
                    case "SQLite":
                        var db_file = GLib.Path.build_filename (config.get_db_path (),
                                                                config.get_db_name ());
                        db_file += ".db";
                        cnc = "DB_DIR=%s;DB_NAME=%s".printf (config.get_db_path (),
                                                             config.get_db_name ());
                        break;
                    default:
                        /* Should never make it here */
                        break;
                }
                conn = Gda.Connection.open_from_string (provider, cnc, null,
                            Gda.ConnectionOptions.THREAD_SAFE);
            }
        } catch (GLib.Error e) {
            error ("An error occurred connecting to the database: %s", e.message);
        }

        dump_db_schema ();
    }

    ~Database () {
        conn.close ();
    }

    /**
     * XXX This is nothing, just used during testing and should be removed later
     */
    private void dump_db_schema () {
        try {
            var meta_store = conn.get_meta_store ();
            var schema = meta_store.schema_get_structure ();
            var db_objs = schema.get_all_db_objects ();
            debug ("%12s%12s%32s%12s", "Catalog", "Schema", "Name", "Type");
            db_objs.@foreach ((obj) => {
                string obj_type = "unknown";
                if (obj.obj_type == Gda.MetaDbObjectType.TABLE) {
                    obj_type = "table";
                } else if (obj.obj_type == Gda.MetaDbObjectType.VIEW) {
                    obj_type = "view";
                }
                debug ("%12s%12s%32s%12s", obj.obj_catalog, obj.obj_schema, obj.obj_name, obj_type);
            });
        } catch (GLib.Error e) {
            warning ("Error while dumping schema: %s", e.message);
        }
    }

    public void create_table (string name, Type type) {
        string sql = "CREATE TABLE IF NOT EXISTS %s".printf (name);
        string[] values = {};
        var ocl = (ObjectClass) type.class_ref ();

        foreach (var spec in ocl.list_properties ()) {
            string? value_type = null;

            /* FIXME This may only work for SQLite */
            if (spec.value_type == typeof (string)) {
                value_type = "STRING";
            } else if (spec.value_type == typeof (bool)) {
                value_type = "BOOLEAN";
            } else if (spec.value_type == typeof (int)) {
                value_type = "INTEGER";
            } else if (spec.value_type == typeof (long)) {
                value_type = "BIGINT";
            } else if (spec.value_type == typeof (float)) {
                value_type = "FLOAT";
            } else if (spec.value_type == typeof (double)) {
                value_type = "DOUBLE";
            } else {
                /* Seemed like a reasonable way to check for blob types */
                if (spec.get_blurb () == "blob") {
                    value_type = "STRING";
                }
            }

            /* Skip unrecognized property types */
            if (value_type == null) {
                continue;
            }

            var value = "%s %s".printf (spec.get_name (), value_type);
            if (spec.get_nick () == "primary_key") {
                value += " NOT NULL PRIMARY KEY";
            }

            values += value;
        }

        sql += " (";
        for (int i = 0; i < values.length; i++) {
            sql += values[i];
            if (i != values.length - 1) {
                sql += ", ";
            }
        }
        sql += ")";

        try {
            conn.execute_non_select_command (sql);
            debug ("SQL: [%s]", sql);
            conn.update_meta_store (null);
        } catch (GLib.Error e) {
            critical ("Error creating table '%s': %s", name, e.message);
        }
    }

    public void delete_table (string name) {
        try {
            conn.execute_non_select_command ("DROP TABLE IF EXISTS %s".printf (name));
            conn.update_meta_store (null);
        } catch (GLib.Error e) {
            critical ("Error deleting table '%s': %s", name, e.message);
        }
    }

    public int count (string table) throws GLib.Error {
        var builder = new SqlBuilder (SqlStatementType.SELECT);
        builder.select_add_target (table, null);
        builder.select_add_field ("count(*)", null, null);
        var stmt = builder.get_statement ();
        var dm = conn.statement_execute_select (stmt, null);
        var count = dm.get_value_at (0, 0);

        return count.get_int ();
    }

    /**
     * FIXME Needs to return a record set
     * FIXME This should be a generic Type select with ID (?)
     * FIXME Make the ID field a generic (?)
     * FIXME Read only properties can not be set in the returned object
     * FIXME Using a bool on blob exclude seems hacky, should build query sensibly
     */
    public T[] select<T> (string table, Value? id = null,
                          bool exclude_blobs = true, int n = 0, int offset = 0) throws GLib.Error {
        var ocl = (ObjectClass) typeof (T).class_ref ();
        var builder = new SqlBuilder (SqlStatementType.SELECT);
        builder.select_add_target (table, null);
        if (exclude_blobs) {
            foreach (var spec in ocl.list_properties ()) {
                if (spec.get_blurb () != "blob") {
                    builder.select_add_field (spec.get_name (), null, null);
                }
            }
        } else {
            builder.select_add_field ("*", null, null);
        }

        try {
            string? pk = null;
            T[] result = {};

            foreach (var spec in ocl.list_properties ()) {
                if (spec.get_nick () == "primary_key") {
                    pk = spec.get_name ();
                }
            }

            if (pk == null) {
                throw new DatabaseError.EXECUTE_QUERY (
                    "No primary key was defined for '%s'", table);
            }

            var pk_id = builder.add_id (pk);
            if (id != null) {
                var expr_id = builder.add_expr_value (null, id);
                var cond_id = builder.add_cond (SqlOperatorType.IS, pk_id, expr_id, 0);
                builder.set_where (cond_id);
            } else {
                var expr_start = builder.add_expr_value (null, offset);
                var cond1_id = builder.add_cond (SqlOperatorType.GEQ, pk_id, expr_start, 0);
                if (n != 0) {
                    var expr_end = builder.add_expr_value (null, offset + n);
                    var cond2_id = builder.add_cond (SqlOperatorType.LT, pk_id, expr_end, 0);
                    var cond3_id = builder.add_cond (SqlOperatorType.AND, cond1_id, cond2_id, 0);
                    builder.set_where (cond3_id);
                } else {
                    builder.set_where (cond1_id);
                }
            }



            var stmt = builder.get_statement ();
            var dm = conn.statement_execute_select (stmt, null);

            for (int i = 0; i < dm.get_n_rows (); i++) {
                var obj = Object.@new (typeof (T));
                for (int j = 0; j < dm.get_n_columns (); j++) {
                    var col = dm.get_column_name (j);
                    var val = dm.get_value_at (j, i);
                    unowned ParamSpec? spec = ocl.find_property (col);
                    if (spec == null) {
                        throw new DatabaseError.EXECUTE_QUERY (
                            "The query returned an invalid object definition");
                    }
                    if (spec.get_blurb () == "blob") {
                        obj[col] = Icd.Blob.from_base64 (val.get_string ());
                    } else {
                        if (val.holds (typeof (string))) {
                            obj[col] = val.get_string ();
                        } else if (val.holds (typeof (bool))) {
                            obj[col] = val.get_boolean ();
                        } else if (val.holds (typeof (int))) {
                            obj[col] = val.get_int ();
                        } else if (val.holds (typeof (long))) {
                            obj[col] = val.get_long ();
                        } else if (val.holds (typeof (float))) {
                            obj[col] = val.get_float ();
                        } else if (val.holds (typeof (double))) {
                            obj[col] = val.get_double ();
                        }
                    }
                }

                result += obj;
            }

            return result;
        } catch (GLib.Error e) {
            throw new DatabaseError.EXECUTE_QUERY (
                "Could not read record from '%s': %s", table, e.message);
        }
    }

    public void insert<T> (string table, T object, out Value id) throws GLib.Error {
        var builder = new SqlBuilder (SqlStatementType.INSERT);
        builder.set_table (table);
        try {
            string[] columns = {};
            var ocl = (ObjectClass) typeof (T).class_ref ();

            foreach (var spec in ocl.list_properties ()) {
                if (spec.get_nick () != "primary_key") {
                    columns += spec.get_name ();
                }
            }

            /* FIXME See update for example that doesn't do this nonsense */
            for (int i = 0; i < columns.length; i++) {
                unowned ParamSpec? spec = ocl.find_property (columns[i]);
                if (spec.value_type == typeof (string)) {
                    string val;
                    ((Object) object).get (columns[i], out val);
                    builder.add_field_value_as_gvalue (columns[i], val);
                } else if (spec.value_type == typeof (bool)) {
                    bool val;
                    ((Object) object).get (columns[i], out val);
                    builder.add_field_value_as_gvalue (columns[i], val);
                } else if (spec.value_type == typeof (int)) {
                    int val;
                    ((Object) object).get (columns[i], out val);
                    builder.add_field_value_as_gvalue (columns[i], val);
                } else if (spec.value_type == typeof (long)) {
                    long val;
                    ((Object) object).get (columns[i], out val);
                    builder.add_field_value_as_gvalue (columns[i], val);
                } else if (spec.value_type == typeof (float)) {
                    float val;
                    ((Object) object).get (columns[i], out val);
                    builder.add_field_value_as_gvalue (columns[i], val);
                } else if (spec.value_type == typeof (double)) {
                    double val;
                    ((Object) object).get (columns[i], out val);
                    builder.add_field_value_as_gvalue (columns[i], val);
                } else if (spec.get_blurb () == "blob") {
                    Icd.Blob blob;
                    string val;
                    ((Object) object).get (columns[i], out blob);
                    val = blob.to_base64 ();
                    builder.add_field_value_as_gvalue (columns[i], val);
                }
            }

            try {
                Set last_insert_row, out_params;
                var stmt = builder.get_statement ();
                stmt.get_parameters (out out_params);
                conn.statement_execute_non_select (stmt, out_params, out last_insert_row);
            } catch (Error e) {
                critical (e.message);
            }

             /*get the id*/
            string sql = "SELECT COUNT (*) FROM %s".printf (table);
            var dm = conn.execute_select_command (sql);
            id = dm.get_value_at (0, 0);
        } catch (GLib.Error e) {
            throw new DatabaseError.EXECUTE_QUERY (
                "Error creating '%s' record: %s", table, e.message);
        }
    }

    /**
     * FIXME This should be a generic Type update with ID (?)
     */
    public void update<T> (string table, T object) throws GLib.Error {
        try {
            /* FIXME This is dumb */
            int id = -1;
            var sql = "UPDATE %s SET".printf (table);
            var ocl = (ObjectClass) typeof (T).class_ref ();

            foreach (var spec in ocl.list_properties ()) {
                var val = Value (spec.value_type);
                ((Object) object).get_property (spec.get_name (), ref val);
                if (spec.get_nick () == "primary_key") {
                    id = (int) val;
                } else {
                    sql += " %s = %s,".printf (spec.get_name (), val.strdup_contents ());
                }
            }

            sql.data[sql.length - 1] = ' ';
            sql += "WHERE id = %d".printf (id);
            conn.execute_non_select_command (sql);
        } catch (GLib.Error e) {
            throw new DatabaseError.EXECUTE_QUERY (
                "Error updating '%s' record: %s", table, e.message);
        }
    }

    /**
     * FIXME This should be a generic Type delete with ID (?)
     * FIXME Make the ID field a generic
     * FIXME Include a Type to lookup name of ID field
     */
    public void delete (string table, Value? id = null) throws GLib.Error {
        try {
            var sql = "DELETE FROM %s".printf (table);
            sql += (id == null) ? "" : " WHERE id = %d".printf (id.get_int ());
            /*debug (sql);*/
            conn.execute_non_select_command (sql);
        } catch (GLib.Error e) {
            throw new DatabaseError.EXECUTE_QUERY (
                "Error deleting '%s' record: %s", table, e.message);
        }
    }

    public void delete_where (string table, string param, string value) throws GLib.Error {
        try {
            var sql = "DELETE FROM %s".printf (table);
            sql += " WHERE %s = \"%s\"".printf (param, value);
            debug (sql);
            conn.execute_non_select_command (sql);
        } catch (GLib.Error e) {
            throw new DatabaseError.EXECUTE_QUERY (
                "Error deleting '%s' record: %s", table, e.message);
        }
    }

    /**
     * TODO Add a generic Record type
     * XXX This requires libgda-6.0 which is still unstable/unreleased
     */
    /*
     *public class Record<T> : GdaData.Record {
     *}
     */
}
