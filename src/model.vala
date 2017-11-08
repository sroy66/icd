public class Icd.Model : GLib.Object {

    /* FIXME Put all database related stuff into this database object */
    private Icd.Database db;

    private static Once<Icd.Model> _instance;

    /* Object repositories */
    public Repository<Icd.Camera?> cameras { get; construct set; }
    public Repository<Icd.Image?> images { get; construct set; }
    public Repository<Icd.Job?> jobs { get; construct set; }

    /**
     * @return Singleton for the Config class
     */
    public static unowned Icd.Model get_default () {
        return _instance.once (() => { return new Icd.Model (); });
    }

    public void init () {
        db = new Icd.Database ();

        /* Create object repositories */
        cameras = new Repository<Icd.Camera?> (db);
        images = new Repository<Icd.Image?> (db);
        jobs = new Repository<Icd.Job?> (db);
    }

    public class Repository<T> : GLib.Object {

        private Icd.Database db;
        protected string name;

        public Repository (Icd.Database db) {
            this.db = db;
            debug ("Created repository for %s objects", typeof (T).name ());
            /* FIXME This could be (more) generic */
            if (typeof (T).is_a (typeof (Icd.Image))) {
                name = "images";
            } else if (typeof (T).is_a (typeof (Icd.Camera))) {
                name = "cameras";
            } else if (typeof (T).is_a (typeof (Icd.Job))) {
                name = "jobs";
            }

            var config = Icd.Config.get_default ();

            try {
                if (config.get_db_reset ()) {
                    db.delete_table (name);
                }
                db.create_table (name, typeof (T));
            } catch (Error e) {
                critical ("Error: %s", e.message);
            }
        }

        public virtual int count () {
            int n = 0;

            try {
                n = db.count (name);
            } catch (GLib.Error e) {
                critical (e.message);
            }

            return n;
        }

        /**
         * @return The id which is also the primary key value from the database
         */
        public virtual int create (T object) {
            Value id;
            try {
                db.insert (name, object, out id);
                /*debug ("id: %d", id.get_int ());*/
            } catch (GLib.Error e) {
                critical (e.message);
            }

            return id.get_int ();
        }

        public virtual T? read (int id, bool exclude_blobs = true) {
            T[] records;
            try {
                var val_id = Value (typeof (int));
                val_id.set_int (id);
                records = db.select (name, val_id, exclude_blobs);
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

        public virtual GLib.SList<T> read_all (bool exclude_blobs = true) {
            var list = new GLib.SList<T> ();
            try {
                T[] records = db.select (name, null, exclude_blobs);
                foreach (var record in records) {
                    list.append (record);
                }
            } catch (GLib.Error e) {
                critical (e.message);
            }
            return list;
        }

        public virtual GLib.SList<T> read_num (int n, int offset, bool exclude_blobs = true) {
            var list = new GLib.SList<T> ();
            try {
                /*debug ("read_num (%d, %d, %s)", n, offset, exclude_blobs.to_string ());*/
                T[] records = db.select (name, null, exclude_blobs, n, offset);
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
                /*debug ("%d %d", id, val_id.get_int ());*/
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
    public class ImageRepository : Repository<Icd.Image?> {

        public ImageRepository (Icd.Database db) {
            base (db);
            name = "images";
        }

        public override Icd.Image? read (int id, bool exclude_blobs) {
            return null;
        }
    }

    public class CameraRepository : Repository<Icd.Camera?> {

        public CameraRepository (Icd.Database db) {
            base (db);
            name = "cameras";
            // do the udev stuff
            //udev.uevent.connect (connection_cb);
        }

        private void connection_cb () {
            /*
             *if (evt == add) {
             *    var cam = new Camera ();
             *    cam.initialize ();
             *    // fill in cam ?
             *    create (cam);
             *} else if (evt == remove) {
             *    list = read_all ();
             *    for (cam in list) {
             *        if (cam.devname == evt.get("DEVNAME") {
             *            delete (cam.id);
             *        }
             *    }
             *}
             */
        }
    }
}
