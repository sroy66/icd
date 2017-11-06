public class Icd.Blob : GLib.Object {
    public uint8[] data;
    public ulong length;

    public static Icd.Blob.from_length (ulong length) {
        this.length = length;
        data = new uint8[length];
    }

    public void initialize (ulong length) {
        this.length = length;
        data = new uint8[length];
    }

    public static Icd.Blob from_base64 (string text) {
        Icd.Blob blob = new Icd.Blob ();
        var decoded = Base64.decode (text);
        blob.data = decoded;
        blob.length = decoded.length;

        return blob;
    }

    /*
     *public static Icd.Blob from_length (ulong length) {
     *    this.length = length;
     *    data = new uint8[length];
     *}
     */

    public uint8[] to_array () {
        uint8[] ary = new uint8[length];
        Posix.memcpy (ary, data, length);

        return ary;
    }

    public string to_base64 () {
        //var ary = to_array ();
        //var encoded = Base64.encode (ary);
        var encoded = Base64.encode (data);
        return encoded;
    }
}

public class Icd.Image : GLib.Object, Json.Serializable {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    public string name { get; set; }

    public long timestamp { get; set; }

    public int width { get; set; }

    public int height { get; set; }

    [Description(nick = "image_data", blurb="blob")]
    public Icd.Blob data { get; set; }

    public signal void changed (int id, string property);

    construct {
        data = new Icd.Blob ();
    }

    public Image.full (string name,
                       long timestamp,
                       int width,
                       int height,
                       Icd.Blob data) {
        this.name = name;
        this.timestamp = timestamp;
        this.width = width;
        this.height = height;
        this.data = data;
    }

    public string to_string () {
        string str = "{ \"id\": %d, \"name\": \"%s\",
                  \"timestamp\": %ld, \"width\": %d, \"height\": %d}".printf (
                  id, name, timestamp, width, height
        );
        return str;
    }

    public Json.Node serialize_property (string property_name,
                                         Value value,
                                         ParamSpec pspec) {
        Json.Node node = null;

        if (property_name == "data") {
            node = new Json.Node (Json.NodeType.VALUE);
            node.set_string (data.to_base64 ());
        } else if (property_name == "timestamp") {
            node = new Json.Node (Json.NodeType.VALUE);
            node.set_int ((int64) value.get_long ());
        } else {
            node = default_serialize_property (property_name, value, pspec);
        }

        return node;
    }

    public bool deserialize_property (string property_name,
                                      out Value value,
                                      ParamSpec pspec,
                                      Json.Node property_node) {
        if (property_name == "data") {
            warning ("Image data can't be deserialized from JSON yet");
            return false;
        } else if (property_name == "timestamp") {
            value = Value (typeof (long));
            value.set_long ((long) property_node.get_int ());
            return true;
        } else {
            value = property_node.get_value ();
            return true;
        }
    }

    public unowned ParamSpec? find_property (string name) {
        foreach (var property in list_properties ()) {
            if (property.get_name () == name) {
                return property;
            }
        }
        return null;
    }
}
