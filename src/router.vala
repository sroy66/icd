using GPhoto;
using VSGI;
using Valum;
using Valum.Static;
using Valum.ContentNegotiation;
using Template;

public class TimeLapse.Router : Valum.Router {

    private Template.Template index;

    construct {
        use (basic ());
        //use (accept ("text/html"));

        use ((req, res, next) => {
            res.headers.append ("Server", "Cis/1.0");
            HashTable<string, string>? @params = new HashTable<string, string> (str_hash, str_equal);
            @params["charset"] = "utf-8";
            res.headers.set_content_type ("text/html", @params);
            return next ();
        });

        once ((req, res, next) => {
            load_templates ();
            return next ();
        });

        /* Routes */
        get ("/", index_cb);
        get ("/static/<path:path>", sequence (serve_from_file (File.new_for_path ("src/static")),
                                              (req, res, next, ctx) => {
            throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
                                             ctx["path"].get_string ());
        }));

        /* XXX Not sure if the subdomain is really necessary for my needs */
        var image_router = new ImageRouter ();
        use (subdomain ("images", image_router.handle));
        use (basepath ("/api/images", image_router.handle));

        var camera_router = new CameraRouter ();
        use (subdomain ("cameras", camera_router.handle));
        use (basepath ("/api/cameras", camera_router.handle));
    }

    private void load_templates () {
        index = new Template.Template (new TemplateLocator ());
        try {
            index.parse_resource ("/templates/index.tmpl");
        } catch (GLib.Error e) {
            error (e.message);
        }
    }

    private bool index_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                                 throws GLib.Error {
        var scope = new Scope ();
        return index.expand (res.body, scope);
    }
}
