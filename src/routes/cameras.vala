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

    private bool view_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        return true;
    }

    private bool edit_cb (Request req, Response res, NextCallback next)
                          throws GLib.Error {
        return true;
    }
}
