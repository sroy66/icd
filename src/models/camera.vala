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

    /* FIXME cature should return an Icd.Image */
    public uint8[] capture ()
                            throws GLib.Error {
        Result ret;
        CameraFile file = null;
        CameraFilePath path;

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
                     *
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

        var result = data_from_file (file);
        FileUtils.close (fd);
        FileUtils.unlink (tmpname);
        return result;
    }

    private uint8[] data_from_file (CameraFile file) {
        Result ret;
        uint8* data;
        uint8[] ary = null;
        ulong data_len;

        ret = file.get_data_and_size (out data, out data_len);
        ary = new uint8[data_len];
        for (int i = 0; i < data_len; i++) {
            ary[i] = *(data + i);
        }
        /*debug ("data.length: %d", ary.length);*/
        return ary;
    }
}
