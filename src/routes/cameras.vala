using VSGI;
using Valum;

public class Icd.CameraRouter : Valum.Router {

    construct {
        once ((req, res, next) => {
            // one time initialization
            return next ();
        });

        get ("/",         view_cb);
        get ("/<int:id>", view_cb);
        put ("/<int:id>", edit_cb);
    }

    private bool view_cb (Request req, Response res, NextCallback next, Context context)
                          throws GLib.Error {
        var id = context["id"];
        res.headers.set_content_type ("application/json", null);
        var model = Icd.Model.get_default ();

        if (id == null) {
            GLib.SList<Icd.Camera> cameras = null;

            cameras = model.cameras.read_all ();
            if (cameras.length () > 0) {
                var camera_array = new Json.Array ();
                var generator = new Json.Generator ();
                generator.pretty = false;

                foreach (var camera in cameras) {
                    camera = new Camera ();
                    camera_array.add_element (Json.gobject_serialize (camera));
                }
                var node = new Json.Node.alloc ();
                node.init_array (camera_array);
                generator.set_root (node);
                size_t len;
                stream.begin (generator.to_data (out len), res.body, (obj, result) => {
                    stream.end (result);
                });
                return generator.to_stream (res.body);
            } else {
                return false;
            }
        } else {

        return false;
        }
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

    private bool edit_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        return true;
    }
}
