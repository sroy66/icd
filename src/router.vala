using VSGI;
using Valum;
using Valum.Static;
using Valum.ContentNegotiation;
using Template;

public class Icd.Router : Valum.Router {

    /*
     *private Template.Template index;
     *private Template.Template image;
     *private Template.Template images;
     *private Template.Template cameras;
     *private Template.TemplateLocator locator;
     */

    construct {
        use (basic ());

        use ((req, res, next) => {
            res.headers.append ("Server", "Icd/1.0");
            HashTable<string, string>? @params = new HashTable<string, string> (str_hash, str_equal);
            @params["charset"] = "utf-8";
            res.headers.set_content_type ("text/html", @params);
            res.headers.append ("Access-Control-Allow-Origin", "*");
            res.headers.append ("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE");
            res.headers.append ("Access-Control-Allow-Headers", "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
            return next ();
        });

        /*
         *once ((req, res, next) => {
         *    load_templates ();
         *    return next ();
         *});
         */

        /* Routes */
        /*
         *get ("/", index_cb);
         *get ("/images", images_cb);
         *get ("/images/<int:id>", image_cb);
         *get ("/cameras", cameras_cb);
         *get ("/static/<path:path>", sequence (serve_from_file (File.new_for_path ("src/static")),
         *                                      (req, res, next, ctx) => {
         *    throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
         *                                     ctx["path"].get_string ());
         *}));
         */

        /* Metrics from system */
        get ("/api/count/<string:table>", count_cb);
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

/*
 *    private void load_templates () {
 *        locator = new TemplateLocator ();
 *        locator.append_search_path (Icd.TEMPLATEDIR);
 *        locator.append_search_path ("/templates");
 *
 *        index = new Template.Template (locator);
 *        image = new Template.Template (locator);
 *        images = new Template.Template (locator);
 *        cameras = new Template.Template (locator);
 *
 *        try {
 *            index.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "index.tmpl")));
 *            image.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "image.tmpl")));
 *            images.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "images.tmpl")));
 *            cameras.parse_file (File.new_for_path (Path.build_filename (Icd.TEMPLATEDIR, "cameras.tmpl")));
 *        } catch (GLib.Error e) {
 *            error (e.message);
 *        }
 *    }
 */

/*
 *    private bool index_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
 *                           throws GLib.Error {
 *        var scope = new Scope ();
 *        return index.expand (res.body, scope);
 *    }
 *
 *    private bool image_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
 *                           throws GLib.Error {
 *        var id = ctx["id"];
 *        var scope = new Scope ();
 *        var image_id = scope.get ("id");
 *        image_id.assign_value (id);
 *
 *        return image.expand (res.body, scope);
 *    }
 *
 *    private bool images_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
 *                            throws GLib.Error {
 *        var scope = new Scope ();
 *        return images.expand (res.body, scope);
 *    }
 *
 *    private bool cameras_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
 *                             throws GLib.Error {
 *        var scope = new Scope ();
 *        return cameras.expand (res.body, scope);
 *    }
 */

    private bool count_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                           throws GLib.Error {
        res.headers.set_content_type ("application/json", null);
        var table = ctx["table"];

        if (table != null) {
            var model = Icd.Model.get_default ();
            var builder = new Json.Builder ();
            var generator = new Json.Generator ();
            int n = 0;
            if (table.get_string () == "images") {
                n = model.images.count ();
            } else if (table.get_string () == "cameras") {
                n = model.cameras.count ();
            } else if (table.get_string () == "jobs") {
                n = model.cameras.count ();
            } else {
                throw new ClientError.BAD_REQUEST ("An invalid table was name provided");
            }
            builder.begin_object ();
            builder.set_member_name ("count");
            builder.add_int_value (n);
            builder.end_object ();

            generator.root = builder.get_root ();
            generator.pretty = false;

            return generator.to_stream (res.body);
        } else {
            throw new ClientError.BAD_REQUEST ("No table name was provided");
        }
    }

    private bool perf_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                          throws GLib.Error {
        var builder = new Json.Builder ();
        var generator = new Json.Generator ();
        res.headers.set_content_type ("application/json", null);

        double value;
        GTop.Cpu cpu;
        GTop.Memory mem;
        GTop.FsUsage fs;

        GTop.get_cpu (out cpu);
        GTop.get_mem (out mem);
        GTop.get_fsusage (out fs, "/");

        builder.begin_object ();
        builder.set_member_name ("cpu");
        builder.begin_object ();
        builder.set_member_name ("value");
        value = (double)(cpu.total - (cpu.idle + cpu.iowait)) / (double)cpu.total;
        builder.add_double_value (value);
        builder.end_object ();
        builder.set_member_name ("mem");
        builder.begin_object ();
        builder.set_member_name ("value");
        value = (double)(mem.total - (mem.free + mem.buffer + mem.cached)) / (double)mem.total;
        builder.add_double_value (value);
        builder.end_object ();
        builder.set_member_name ("hdd");
        builder.begin_object ();
        builder.set_member_name ("value");
        value = (double)fs.bfree / (double)fs.blocks;
        builder.add_double_value (value);
        builder.end_object ();
        builder.end_object ();

        generator.root = builder.get_root ();
        generator.pretty = false;

        return generator.to_stream (res.body);
    }
}
