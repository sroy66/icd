public class TimeLapse.Model : GLib.Object {

    Gee.TreeMap<int, TimeLapse.Camera> cameras;

    public Model () {
        cameras = new Gee.TreeMap<int, TimeLapse.Camera> ();
    }
}
