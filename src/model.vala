public class TimeLapse.Model : GLib.Object {

    /* FIXME Put all database related stuff into this database object */
    private TimeLapse.Database db;

    /* Object repositories */
    public Repository<TimeLapse.Camera?> cameras { get; construct set; }
    public Repository<TimeLapse.Image?> images { get; construct set; }

    public void init () {
        db = new TimeLapse.Database ();

        /* Create object repositories */
        cameras = new Repository<TimeLapse.Camera?> (db);
        images = new Repository<TimeLapse.Image?> (db);
    }

    public class Repository<T> : GLib.Object {

        private TimeLapse.Database db;
        protected string name;

        public Repository (TimeLapse.Database db) {
            this.db = db;
            debug ("Created repository for %s objects", typeof (T).name ());
            /* FIXME This could be (more) generic */
            if (typeof (T).is_a (typeof (TimeLapse.Image))) {
                name = "images";
            } else if (typeof (T).is_a (typeof (TimeLapse.Camera))) {
                name = "cameras";
            }

            db.delete_table (name);
            db.create_table (name, typeof (T));
        }

        public void create (T object) {
            var sql = "INSERT INTO %s".printf (name);
            string[] columns = {};
            var ocl = (ObjectClass) typeof (T).class_ref ();

            foreach (var spec in ocl.list_properties ()) {
                if (spec.get_nick () != "primary_key") {
                    columns += "%s".printf (spec.get_name ());
                }
            }

            sql += " (";
            for (int i = 0; i < columns.length; i++) {
                sql += columns[i];
                if (i != columns.length - 1) {
                    sql += ", ";
                }
            }
            sql += ") VALUES (";
            for (int i = 0; i < columns.length; i++) {
                unowned ParamSpec? spec = ocl.find_property (columns[i]);
                if (spec.value_type == typeof (string)) {
                    string val;
                    ((Object) object).get (columns[i], out val);
                    sql += "\"%s\"".printf (val);
                } else if (spec.value_type == typeof (bool)) {
                    bool val;
                    ((Object) object).get (columns[i], out val);
                    sql += "%s".printf (val.to_string ());
                } else if (spec.value_type == typeof (int)) {
                    int val;
                    ((Object) object).get (columns[i], out val);
                    sql += "%s".printf (val.to_string ());
                } else if (spec.value_type == typeof (long)) {
                    long val;
                    ((Object) object).get (columns[i], out val);
                    sql += "%s".printf (val.to_string ());
                } else if (spec.value_type == typeof (float)) {
                    float val;
                    ((Object) object).get (columns[i], out val);
                    sql += "%s".printf (val.to_string ());
                } else if (spec.value_type == typeof (double)) {
                    double val;
                    ((Object) object).get (columns[i], out val);
                    sql += "%s".printf (val.to_string ());
                } else {
                    if (spec.get_blurb () == "blob") {
                        debug ("Not doing anything with blobs yet");
                    }
                }
                if (i != columns.length - 1) {
                    sql += ", ";
                }
            }
            sql += ")";
        }

        public virtual T? read (int id) {
            return null;
        }

        public Gee.List<T> read_all () {
            var list = new Gee.ArrayList<T> ();
            return list;
        }

        public void update (T object) {
        }

        public void @delete (int id) {
        }
    }

    /**
     * XXX This is currently just here to test overriding methods from base
     */
    public class ImageRepository : Repository<TimeLapse.Image?> {

        public ImageRepository (TimeLapse.Database db) {
            base (db);
            name = "images";
        }

        public override TimeLapse.Image? read (int id) {
            return null;
        }
    }
}
