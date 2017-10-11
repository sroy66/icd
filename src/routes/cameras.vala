using GPhoto;
using VSGI;
using Valum;

public class TimeLapse.CameraRouter : Valum.Router {

    private GPhoto.Camera camera;
    private GPhoto.Context gp_context;

    construct {
        once ((req, res, next) => {
            // one time initialization
            initialize_camera ();
            return next ();
        });

        get ("/",         view_cb);
        get ("/<int:id>", view_cb);
        put ("/<int:id>", edit_cb);
    }

    ~CameraRouter () {
        camera.exit (gp_context);
    }

    /**
     * TODO Throw error if connection fails and use that in an HTTP response
     */
    private void initialize_camera () {
        Result ret;

        ret = GPhoto.Camera.create (out camera);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        }

        gp_context = new GPhoto.Context ();
        ret = camera.init (gp_context);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        }
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

    /**
     * TODO Move this into POST /jobs/
     */
    private bool capture_cb (Request req, Response res, NextCallback next)
                             throws GLib.Error {
        Result ret;
        CameraFile file = null;
        CameraFilePath path;
        string? tmpfilename = null;
        string tmpname = "tmpfileXXXXXX";

        ret = camera.capture (CameraCaptureType.IMAGE, out path, gp_context);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        } else {
            int fd = FileUtils.mkstemp (tmpname);
            if (fd == -1) {
                if (errno == Posix.EACCES) {
                    gp_context.error ("Permission denied");
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
                                       gp_context);
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
