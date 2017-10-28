using GPhoto;
using VSGI;
using Valum;
using Valum.Static;
using Valum.ContentNegotiation;
using Template;

public class Icd.Router : Valum.Router {

    private Template.Template index;
    private Template.Template images;
    private Template.Template cameras;
    private Template.TemplateLocator locator;

    construct {
        use (basic ());

        use ((req, res, next) => {
            res.headers.append ("Server", "Icd/1.0");
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
        get ("/images", images_cb);
        get ("/cameras", cameras_cb);
        get ("/static/<path:path>", sequence (serve_from_file (File.new_for_path ("src/static")),
                                              (req, res, next, ctx) => {
            throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
                                             ctx["path"].get_string ());
        }));

        /* Performance metrics from system */
        get ("/api/perf", perf_cb);

        /* XXX Not sure if the subdomain is really necessary for my needs */
        var image_router = new ImageRouter ();
        use (subdomain ("images", image_router.handle));
        use (basepath ("/api/images", image_router.handle));

        var camera_router = new CameraRouter ();
        use (subdomain ("cameras", camera_router.handle));
        use (basepath ("/api/cameras", camera_router.handle));

        var job_router = new JobRouter ();
        use (subdomain ("jobs", job_router.handle));
        use (basepath ("/api/jobs", job_router.handle));
    }

    private void load_templates () {
        locator = new TemplateLocator ();
        locator.append_search_path (Icd.TEMPLATEDIR);
        locator.append_search_path ("/templates");

        index = new Template.Template (locator);
        images = new Template.Template (locator);
        cameras = new Template.Template (locator);

        try {
            index.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "index.tmpl")));
            images.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "images.tmpl")));
            cameras.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "cameras.tmpl")));
        } catch (GLib.Error e) {
            error (e.message);
        }

        /* FIXME Would like to be able to load templates as resources but includes fail */
        /*
         *var res_tmpl = new Template.Template (locator);
         *res_tmpl.parse_resource ("/templates/index.tmpl");
         */
    }

    private bool index_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                           throws GLib.Error {
        var scope = new Scope ();
        return index.expand (res.body, scope);
    }

    private bool images_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                            throws GLib.Error {
        var scope = new Scope ();
        return images.expand (res.body, scope);
    }

    private bool cameras_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                             throws GLib.Error {
        var scope = new Scope ();
        return cameras.expand (res.body, scope);
    }

    private bool perf_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                          throws GLib.Error {
        var generator = new Json.Generator ();
        res.headers.set_content_type ("application/json", null);
        //generator.root = Json.gobject_serialize (image);
        generator.pretty = false;
        return generator.to_stream (res.body);
    }
}
