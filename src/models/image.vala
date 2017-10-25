public class Icd.Blob {
    public uint8* data;
    public ulong length;

    public uint8[] to_array () {
        uint8[] ary = null;

        ary = new uint8[length];
        for (int i = 0; i < length; i++) {
            ary[i] = *(data + i);
        }
        /*debug ("data.length: %d", ary.length);*/
        return ary;
    }
}

public class Icd.Image : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    public string name { get; set; }

    public long timestamp { get; set; }

    public int width { get; set; }

    public int height { get; set; }

    [Description(nick = "image_data", blurb="blob")]
    public Blob data { get; private set; }

    public signal void changed (int id, string property);

    public Image.full (string name, long timestamp, int width,
                                                    int height,
                                                    Blob data) {
        this.name = name;
        this.timestamp = timestamp;
        this.width = width;
        this.height = height;
        this.data = data;
        debug ("length: %lu",data.length);
    }

    public string to_string () {
        string str = "{ \"id\": %d, \"name\": \"%s\",
                  \"timestamp\": %ld, \"width\": %d, \"height\": %d}".printf (
                  id, name, timestamp, width, height
        );
        return str;
    }
}
