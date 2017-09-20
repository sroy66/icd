using VSGI;
using Valum;

public class TimeLapse.CameraRouter : Valum.Router {

    private GPhoto.Camera camera;
    private GPhoto.Context gp_context;

    construct {
        once ((req, res, next) => {
            // one time initialization
            return next ();
        });

        get ("/",         view_cb);
        get ("/<int:id>", view_cb);
        put ("/<int:id>", edit_cb);
    }

    private bool view_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        res.headers.set_content_type ("image/png", null);
        return res.expand_file (File.new_for_path ("/usr/share/pixmaps/debian-logo.png"));
    }

    private bool edit_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        return true;
    }
}
