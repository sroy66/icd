public errordomain Icd.JobError {
    CAMERA
}

public class Icd.Job : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    /* In seconds */
    public int interval { get; set; }

    private int _count;
    public int count {
        get {
            return _count;
        }
        set {
            _count = value;
            remaining = count;
        }
    }

    public int remaining { get; set; }

    public bool running { get; set; }

    public signal void changed (int id, string property);

    public string to_string () {
        string str = "{ \"id\": %d, \"interval\": %d, \"count\": %d,
            \"running\": %s}".printf (
            id, interval, count, running.to_string ()
        );
        return str;
    }

    public async void run () throws Icd.JobError {
        Icd.Camera camera;

        try {
            camera = new Icd.Camera ();
        } catch (Icd.CameraError e) {
            throw new Icd.JobError.CAMERA (e.message);
        }

        var model = Icd.Model.get_default ();

        running = true;
        while (running) {
            for (int i = count - remaining; i < count; i++) {
                try {
                    /* take a picture and save the image in the database */
                    var image = camera.capture ();
                    /*
                     *debug ("image length: %lu width: %d height: %d",
                     *                                      image.data.length,
                     *                                      image.width,
                     *                                      image.height);
                     */
                    model.images.create (image);
                    yield nap (interval); //FIXME This is not accurate. Use a thread.
                } catch (GLib.Error e) {
                    critical ("GLib.Error: %s", e.message);
                }

                remaining = count - i - 1;
                model.jobs.update (this);
            }

            running = false;
            model.jobs.delete (id);
        }
    }

	public async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
	    GLib.Timeout.add (interval, () => {
		    nap.callback ();

		    return false;
		    }, priority);
	    yield;
	}
}
