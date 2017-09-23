public class TimeLapse.Image : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    public string name { get; set; }

    public long timestamp { get; set; }

    public int width { get; set; }

    public int height { get; set; }

    public signal void changed (int id, string property);
}
