public class TimeLapse.Database : GLib.Object {

    public Gda.Connection conn { get; construct set; }

    public Database () {
        var config = TimeLapse.Config.get_default ();

        /* Establish database connection */
        try {
            var dsn = config.get_db_dsn ();
            if (dsn != null) {
                conn = Gda.Connection.open_from_dsn (dsn, null,
                            Gda.ConnectionOptions.NONE);
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
                            Gda.ConnectionOptions.NONE);
            }
        } catch (GLib.Error e) {
            error ("An error occurred connecting to the database: %s", e.message);
        }
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
                value_type = "REAL";
            } else if (spec.value_type == typeof (float)) {
                value_type = "FLOAT";
            } else if (spec.value_type == typeof (double)) {
                value_type = "DOUBLE";
            } else {
                /* Seemed like a reasonable way to check for blob types */
                if (spec.get_blurb () == "blob") {
                    value_type = "BLOB";
                }
            }

            /* Skip unrecognized property types */
            if (value_type == null) {
                continue;
            }

            var value = "%s %s".printf (spec.get_name (), value_type);
            if (spec.get_nick () == "primary_key") {
                value += " PRIMARY KEY";
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
}
