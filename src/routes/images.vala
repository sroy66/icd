using VSGI;
using Valum;
using Valum.ContentNegotiation;

public class Icd.ImageRouter : Valum.Router {

    construct {
        once ((req, res, next) => {
            return next ();
        });

        rule (Method.GET,
              "/(<int:id>)?(/<action>)?",
              view_cb);
        rule (Method.GET,
              "(/n/<int:n>)?(/offset/<int:offset>)?",
              view_cb);
        rule (Method.PUT,
              "/<int:id>",
              accept ("application/json", edit_cb));
        rule (Method.POST,
              "/",
              accept ("application/json", create_cb));
        rule (Method.DELETE,
              "/(<int:id>)?",
              delete_cb);
    }

    private async void stream (string data, OutputStream os) {
        size_t bytes;
        try {
            yield os.write_all_async (data.data, Priority.DEFAULT, null, out bytes);
        } catch (GLib.Error e) {
            /* FIXME throw the error to allow the route to do the same */
            critical (e.message);
        }
    }

    private bool view_cb (Request req, Response res, NextCallback next, Context context)
                          throws GLib.Error {
        var id = context["id"];
        var action = context["action"];
        var n = context["n"];
        var offset = context["offset"];
        bool exclude_blobs = true;
        string action_str = "none";

        if (action != null) {
            exclude_blobs = (action.get_string () == "all") ? false : true;
            action_str = action.get_string ();
        }

        res.headers.set_content_type ("application/json", null);

        var model = Icd.Model.get_default ();
        if (id == null) { // means get a range of images with
            GLib.SList<Icd.Image> images = null;
            var n_str = n.get_string ();
            var offset_str = offset.get_string ();
            if ((n_str == null) && (offset_str == null)) {
                images = model.images.read_all (true);
            } else {
                int n_int = 0;
                int offset_int = 0;

                if (offset_str != null) {
                    offset_int = int.parse (offset_str);
                }
                if (n_str != "") {
                    n_int = int.parse (n_str);
                }
                images = model.images.read_num (n_int, offset_int, exclude_blobs);
            }

            if (images.length () > 0) {
                var image_array = new Json.Array ();
                var generator = new Json.Generator ();
                generator.pretty = false;

                if (action_str == "all") {
                    foreach (var image in images) {
                        image_array.add_element (Json.gobject_serialize (image));
                    }

                    var node = new Json.Node.alloc ();
                    node.init_array (image_array);
                    generator.set_root (node);
                    size_t len;
                    stream.begin (generator.to_data (out len), res.body, (obj, result) => {
                        stream.end (result);
                    });
                    return true;
                } else {
                    /* TODO create array with just info nodes */
                    foreach (var image in images) {
                        var object = new Json.Object ();
                        /* FIXME should probably serialize and drop the data property */
                        object.set_int_member ("id", image.id);
                        object.set_string_member ("name", image.name);
                        object.set_int_member ("timestamp", (int64) image.timestamp);
                        object.set_int_member ("width", image.width);
                        object.set_int_member ("height", image.height);

                        var node = new Json.Node (Json.NodeType.OBJECT);
                        node.set_object (object);
                        image_array.add_element (node);
                    }

                    var node = new Json.Node.alloc ();
                    node.init_array (image_array);
                    generator.set_root (node);

                    return generator.to_stream (res.body);
                }
            } else {
                /* FIXME Need to return a proper code in the response */
                throw new ClientError.NOT_FOUND (
                    "No images were found");
            }
        } else {
            var image = model.images.read (int.parse (id.get_string ()), exclude_blobs);
            if (image != null) {
                var generator = new Json.Generator ();
                generator.pretty = false;

                if (action_str == "all") {
                    generator.root = Json.gobject_serialize (image);
                    size_t len;
                    stream.begin (generator.to_data (out len), res.body, (obj, result) => {
                        stream.end (result);
                    });
                    return true;
                } else {
                    var object = new Json.Object ();
                    object.set_int_member ("id", image.id);
                    object.set_string_member ("name", image.name);
                    object.set_int_member ("timestamp", (int64) image.timestamp);
                    object.set_int_member ("width", image.width);
                    object.set_int_member ("height", image.height);

                    var node = new Json.Node (Json.NodeType.OBJECT);
                    node.set_object (object);
                    generator.root = node;

                    return generator.to_stream (res.body);
                }
            } else {
                /* FIXME Need to return a proper code in the response */
                throw new ClientError.NOT_FOUND (
                    "No image was found with the ID provided");
            }
        }
    }

    private bool edit_cb (Request req, Response res, NextCallback next, Context context, string content_type)
                          throws GLib.Error {
        var id = context["id"];
        if (id == null) {
            throw new ClientError.NOT_FOUND ("No image ID was provided");
        }

        switch (content_type) {
            case "application/json":
                try {
                    var model = Icd.Model.get_default ();
                    var image = model.images.read (int.parse (id.get_string ()));
                    var parser = new Json.Parser ();
                    parser.load_from_stream (req.body);
                    var node = parser.get_root ();
                    var obj = node.get_object ();
                    obj.foreach_member ((prop, name, prop_node) => {
                        ((Object) image).set_property (name, prop_node.get_value ());
                    });
                    model.images.update (image);
                } catch (GLib.Error e) {
                    throw new ClientError.BAD_REQUEST (
                        "Invalid or malformed JSON was provided");
                }
                break;
            default:
                throw new ClientError.BAD_REQUEST (
                    "Request used incorrect content type, 'application/json' expected");
        }
        return res.end ();
    }

    private bool create_cb (Request req, Response res, NextCallback next, Context context, string content_type)
                            throws GLib.Error {
        switch (content_type) {
            case "application/json":
                try {
                    var parser = new Json.Parser ();
                    parser.load_from_stream (req.body);
                    var image = Json.gobject_deserialize (typeof (Icd.Image),
                                                          parser.get_root ());
                    var model = Icd.Model.get_default ();
                    model.images.create ((Icd.Image) image);
                } catch (GLib.Error e) {
                    throw new ClientError.BAD_REQUEST (
                        "Invalid or malformed JSON was provided");
                }
                break;
            default:
                throw new ClientError.BAD_REQUEST (
                    "Request used incorrect content type, 'application/json' expected");
        }

        return res.end ();
    }

    private bool delete_cb (Request req, Response res, NextCallback next, Context context)
                            throws GLib.Error{
        var id = context["id"];
        var model = Icd.Model.get_default ();
        if (id != null) {
            model.images.delete (int.parse (id.get_string ()));
        } else {
            model.images.delete_all ();
        }

        return res.end ();
    }
}
