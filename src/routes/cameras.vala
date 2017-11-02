using VSGI;
using Valum;

public class Icd.CameraRouter : Valum.Router {

    construct {
        once ((req, res, next) => {
            // one time initialization
            return next ();
        });

        use ((req, res, next) => {
            res.headers.append ("Access-Control-Allow-Origin", "*");
            return next ();
        });

        get ("/",         view_cb);
        get ("/<int:id>", view_cb);
        put ("/<int:id>", edit_cb);
    }

    private bool view_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        res.headers.set_content_type ("image/png", null);
        return res.expand_file (File.new_for_path ("/usr/share/pixmaps/fedora-logo.png"));
    }

    private bool edit_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        return true;
    }
}
