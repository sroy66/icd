using GPhoto;

public class Icd.Camera : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    public string name { get; set; }

    private GPhoto.Camera camera;
    private GPhoto.Context gp_context;

    construct {
        initialize_camera ();
    }

    ~Camera () {
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

    public Icd.Image capture () throws GLib.Error {
        Result ret;
        CameraFile file = null;
        CameraFilePath path;
        Icd.Image image = null;

        string tmpname = "tmpfileXXXXXX";
        int fd = -1;

        ret = camera.capture (CameraCaptureType.IMAGE, out path, gp_context);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        } else {
            fd = FileUtils.mkstemp (tmpname);
            if (fd == -1) {
                if (errno == Posix.EACCES) {
                    gp_context.error ("Permission denied");
                }
            } else {
                ret = CameraFile.create_from_fd (out file, fd);
            }

            if (file != null) {
                ret = camera.get_file ((string) path.folder,
                                    (string) path.name,
                                    CameraFileType.NORMAL,
                                    file,
                                    gp_context);
                if (ret != Result.OK) {
                    critical (ret.to_full_string ());
                } else {
                    /*
                     *FIXME get timestamp, width, length..
                     *CameraFileInfo info;
                     *ret = camera.get_file_info ((string) path.folder,
                     *                            file,
                     *                            info,
                     *                            gp_context);
                     */
                    if (ret != Result.OK) {
                        critical (ret.to_full_string ());
                    } else {

                    }
                }
            }
        }

        uint8* data;
        ulong data_len;
        ret = file.get_data_and_size (out data, out data_len);
        Icd.Blob blob = new Icd.Blob ();
        Posix.memcpy (blob.data, data, data_len);
        blob.length = data_len;
        debug ("image data length: %lu %lu", data_len, blob.length);

        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        } else {
            /* FIXME only the data property is being set for now */
            image = new Image.full ("name", 0, -1, -1, blob);
        }

        FileUtils.close (fd);
        FileUtils.unlink (tmpname);

        return image;
    }
}
