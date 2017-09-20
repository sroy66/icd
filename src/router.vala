using GPhoto;
using VSGI;
using Valum;
using Valum.Static;
using Valum.ContentNegotiation;
using Template;

public class TimeLapse.Router : Valum.Router {

    private Template.Template index;

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

        /* Connect to the database */
        once ((req, res, next) => {
            connect_db ();
            return next ();
        });

        /* Routes */
        get ("/", index_cb);
        get ("/static/<path:path>", sequence (serve_from_file (File.new_for_path ("src/static")),
                                                (req, res, next, ctx) => {
            throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
                                            ctx["path"].get_string ());
        }));

        var image_router = new ImageRouter ();
        use (subdomain ("images", image_router.handle));
        use (basepath ("/api/images", image_router.handle));

        var camera_router = new CameraRouter ();
        use (subdomain ("cameras", camera_router.handle));
        use (basepath ("/api/cameras", camera_router.handle));
    }

    private void connect_db () {
    }

    private bool index_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                                 throws GLib.Error {
        var scope = new Scope ();
        return index.expand (res.body, scope);
    }
}
