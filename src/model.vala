public class TimeLapse.Model : GLib.Object {

    /* FIXME Put all database related stuff into this database object */
    private TimeLapse.Database db;

    private static Once<TimeLapse.Model> _instance;

    /* Object repositories */
    public Repository<TimeLapse.Camera?> cameras { get; construct set; }
    public Repository<TimeLapse.Image?> images { get; construct set; }

    /**
     * @return Singleton for the Config class
     */
    public static unowned TimeLapse.Model get_default () {
        return _instance.once (() => { return new TimeLapse.Model (); });
    }

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

        public virtual void create (T object) {
            try {
                db.insert (name, object);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }

        public virtual T? read (int id) {
            T[] records;
            try {
                var val_id = Value (typeof (int));
                val_id.set_int (id);
                records = db.select (name, val_id);
                /* FIXME This should probably throw an exception instead */
                if (records.length == 0) {
                    critical ("Read failed for ID '%d'", id);
                    return null;
                }
            } catch (GLib.Error e) {
                critical (e.message);
            }
            return records[0];
        }

        public virtual GLib.SList<T> read_all () {
            var list = new GLib.SList<T> ();
            try {
                T[] records = db.select (name);
                foreach (var record in records) {
                    list.append (record);
                }
            } catch (GLib.Error e) {
                critical (e.message);
            }
            return list;
        }

        public virtual void update (T object) {
            try {
                db.update (name, object);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }

        public virtual void delete (int id) {
            try {
                var val_id = Value (typeof (int));
                val_id.set_int (id);
                db.delete (name, val_id);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }

        public virtual void delete_all () {
            try {
                db.delete (name, null);
            } catch (GLib.Error e) {
                critical (e.message);
            }
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
