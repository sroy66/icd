public class TimeLapse.Config : GLib.Object {

    private GLib.KeyFile file;

    private static Once<TimeLapse.Config> _instance;

    public bool is_loaded { get; construct set; default = false; }

    public static unowned TimeLapse.Config get_default () {
        return _instance.once (() => { return new TimeLapse.Config (); });
    }

    public void load_from_file (string filename) throws GLib.Error {
        is_loaded = true;
        file = new GLib.KeyFile ();
        try {
            file.load_from_file (filename, KeyFileFlags.NONE);
        } catch (GLib.Error e) {
            throw e;
        }
    }

    public string get_address () throws GLib.Error {
        string value;

        try {
            value = file.get_string ("general", "address");
        } catch (GLib.Error e) {
            throw e;
        }

        return value;
    }

    public int get_port () throws GLib.Error {
        int value;

        try {
            value = file.get_integer ("general", "port");
        } catch (GLib.Error e) {
            throw e;
        }

        return value;
    }

    public string get_db_host () throws GLib.Error {
        string value;

        try {
            value = file.get_string ("database", "host");
        } catch (GLib.Error e) {
            throw e;
        }

        return value;
    }

    public int get_db_port () throws GLib.Error {
        int value;

        try {
            value = file.get_integer ("database", "port");
        } catch (GLib.Error e) {
            throw e;
        }

        return value;
    }

    public string get_db_name () throws GLib.Error {
        string value;

        try {
            value = file.get_string ("database", "name");
        } catch (GLib.Error e) {
            throw e;
        }

        return value;
    }

    public string get_db_password () throws GLib.Error {
        string value;

        try {
            value = file.get_string ("database", "password");
        } catch (GLib.Error e) {
            throw e;
        }

        return value;
    }
}
