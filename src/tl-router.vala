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

        rule (Method.GET, "/", route_index_cb);
        get ("/static/<path:path>", sequence (serve_from_file (File.new_for_path ("src/static")),
                                                (req, res, next, ctx) => {
            throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
                                            ctx["path"].get_string ());
        }));

        var image_router = new ImageRouter ();
        use (subdomain ("image", image_router.handle));
        use (basepath ("/image", image_router.handle));
    }

    private void connect_db () {
    }

    private bool route_index_cb (Request req, Response res, NextCallback next, Valum.Context ctx)
                                 throws GLib.Error {
        var scope = new Scope ();
        return index.expand (res.body, scope);
    }
}

public class TimeLapse.ImageRouter : Valum.Router {

    private Camera camera;
    private GPhoto.Context context;

    construct {
        once ((req, res, next) => {
            initialize_camera ();
            return next ();
        });

        rule (Method.GET,               "/",          route_view_cb);
        rule (Method.GET | Method.POST, "/<int:id>",  route_edit_cb);
        rule (Method.GET,               "/capture",   route_capture_cb);
    }

    ~ImageRouter () {
        camera.exit (context);
    }

    /**
     * TODO Throw error if connection fails and use that in an HTTP response
     */
    private void initialize_camera () {
        Result ret;

        ret = Camera.create (out camera);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        }

        context = new GPhoto.Context ();
        ret = camera.init (context);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        }
    }

    private bool route_view_cb (Request req, Response res, NextCallback next)
                                throws GLib.Error {
        res.headers.set_content_type ("image/png", null);
        return res.expand_file (File.new_for_path ("/usr/share/pixmaps/debian-logo.png"));
    }

    private bool route_edit_cb (Request req, Response res, NextCallback next)
                                throws GLib.Error {
        return true;
    }

    private bool route_capture_cb (Request req, Response res, NextCallback next) {
        Result ret;
        CameraFile file = null;
        CameraFilePath path;
        string? tmpfilename = null;
        string tmpname = "tmpfileXXXXXX";

        ret = camera.capture (CameraCaptureType.IMAGE, out path, context);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        } else {
            int fd = FileUtils.mkstemp (tmpname);
            if (fd == -1) {
                if (errno == Posix.EACCES) {
                    context.error ("Permission denied");
                }
            } else {
                ret = CameraFile.create_from_fd (out file, fd);
                if (ret < Result.OK) {
                    FileUtils.close (fd);
                    FileUtils.unlink (tmpname);
                } else {
                    tmpfilename = tmpname;
                }
            }

            if (file != null) {
                ret = camera.get_file ((string) path.folder,
                                       (string) path.name,
                                       CameraFileType.NORMAL,
                                       file,
                                       context);
                if (ret < Result.OK) {
                    if (tmpfilename != null) {
                        critical (ret.to_full_string ());
                    }
                }
            }
        }

        res.headers.set_content_type ("image/png", null);
        if (file != null) {
            return res.expand_file (File.new_for_path (tmpfilename));
        } else {
            // TODO send error response
            return res.expand_file (File.new_for_path ("/usr/share/pixmaps/debian-logo.png"));
        }
    }
}
