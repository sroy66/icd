public class Icd.Job : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    /* In seconds */
    public int interval { get; set; }

    public int count { get; set; }

    public signal void changed (int id, string property);

    public string to_string () {
        string str = "{ \"id\": %d, \"interval\": %d, \"count\": %d}".printf (
            id, interval, count
        );
        return str;
    }
}
