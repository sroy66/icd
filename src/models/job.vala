public class Icd.Job : GLib.Object {

    [Description(nick = "primary_key")]
    public int id { get; construct set; }

    /* In seconds */
    public int interval { get; set; }

    public int count { get; set; }

    public bool running { get; set; }

    public signal void changed (int id, string property);

    construct {
    }

    public string to_string () {
        string str = "{ \"id\": %d, \"interval\": %d, \"count\": %d,
            \"running\": %s}".printf (
            id, interval, count, running.to_string ()
        );
        return str;
    }

    public async void run () {
        var camera = new Icd.Camera ();
        var model = Icd.Model.get_default ();

        running = true;
        while (running) {
            for (int i = 0; i < count; i++) {
                try {
                    /* take a picture and save the image in the database */
                    var image = camera.capture ();
                    debug ("image length: %lu", image.data.length);
                    model.images.create (image);
                    yield nap (interval); //FIXME This is not accurate. Use a thread.
                } catch (GLib.Error e) {
                    critical ("GLib.Error: %s", e.message);
                }
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
