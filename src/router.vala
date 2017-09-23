using GPhoto;
using VSGI;
using Valum;
using Valum.Static;
using Valum.ContentNegotiation;
using Template;

public class TimeLapse.Router : Valum.Router {

    public TimeLapse.Model model { get; construct; }

    private Template.Template index;

    public Router (TimeLapse.Model model) {
        GLib.Object (model: model);
    }

    construct {
        /* Templates */
        index = new Template.Template (new TemplateLocator ());
        try {
            index.parse_resource ("/templates/index.tmpl");
        } catch (GLib.Error e) {
            error (e.message);
        }

        use (basic ());
        use (accept ("text/html"));

        once ((req, res, next) => {
            return next ();
        });

        /* Routes */
        get ("/", index_cb);
        get ("/static/<path:path>", sequence (serve_from_file (File.new_for_path ("src/static")),
                                              (req, res, next, ctx) => {
            throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
                                             ctx["path"].get_string ());
        }));

/*
 *        var image_router = new ImageRouter (model);
 *        //use (subdomain ("images", image_router.handle));
 *        use (basepath ("/images", image_router.handle));
 *        //rule (Method.GET | Method.POST | Method.PUT | Method.DELETE, "/api/images", image_router.handle);
 *
 *        var camera_router = new CameraRouter (model);
 *        //use (subdomain ("cameras", camera_router.handle));
 *        use (basepath ("/cameras", camera_router.handle));
 */
    }

    private bool index_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                                 throws GLib.Error {
        var scope = new Scope ();
        return index.expand (res.body, scope);
    }
}
