using GPhoto;

public errordomain Icd.CameraError {
    INITIALIZE,
    CAPTURE
}

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
    private void initialize_camera () throws Icd.CameraError {
        Result ret;

        ret = GPhoto.Camera.create (out camera);
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
            throw new Icd.CameraError.INITIALIZE (
                    "Camera initialization failed: %s".printf (ret.to_full_string ()));
        }

        gp_context = new GPhoto.Context ();
        ret = camera.init (gp_context);
        if (ret != Result.OK) {
            throw new Icd.CameraError.INITIALIZE (
                    "Camera initialization failed: %s".printf (ret.to_full_string ()));
        }
    }

    public Icd.Image capture () throws Icd.CameraError {
        Result ret;
        CameraFile file = null;
        CameraFilePath path;
        Icd.Image image;

        uint8 *data;
        ulong data_len;
        string tmpname = "tmpfileXXXXXX";
        int fd = -1;
        long timestamp = 0;
        int width = 0, height = 0;

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
                    CameraFileInfo info;
                    ret = camera.get_file_info ((string) path.folder,
                                                (string) path.name,
                                                out info,
                                                gp_context);
                    if (ret != Result.OK) {
                        critical (ret.to_full_string ());
                    } else {
                        timestamp = info.file.mtime;
                        width = (int) info.file.width;
                        height = (int) info.file.height;
                    }
                }
            }
        }

        ret = file.get_data_and_size (out data, out data_len);

        /**
         * TODO Throw error if previous data retrieval fails
         */
        if (ret != Result.OK) {
            critical (ret.to_full_string ());
        }

        image = new Icd.Image ();
        /* FIXME Make a real name */
        image.name = "Image";
        image.timestamp = timestamp;
        image.width = width;
        image.height = height;
        var blob = image.data;
        //blob.length = data_len;
        blob.initialize (data_len);

        //Icd.Blob blob = new Icd.Blob.from_length (data_len);
        Posix.memcpy (blob.data, data, (size_t) data_len);
        //image.data = blob;

        FileUtils.close (fd);
        FileUtils.unlink (tmpname);

        return image;
    }
}
