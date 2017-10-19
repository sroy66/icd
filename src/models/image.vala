public class Icd.Image : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    public string name { get; set; }

    public long timestamp { get; set; }

    public int width { get; set; }

    public int height { get; set; }

    [Description(nick="image_data", blurb="blob")]
    public uint8[] data { get; set; }

    public signal void changed (int id, string property);

    public Image.full (string name, long timestamp, int width, int height) {
        this.name = name;
        this.timestamp = timestamp;
        this.width = width;
        this.height = height;
    }

    public string to_string () {
        string str = "{ \"id\": %d, \"name\": \"%s\", \"timestamp\": %ld, \"width\": %d, \"height\": %d}".printf (
            id, name, timestamp, width, height
        );
        return str;
    }
}
