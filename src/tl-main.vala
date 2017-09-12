public class TimeLapse.Main : GLib.Object {

	public TimeLapse.App app;
    public TimeLapse.Config config;

    private Main () {
        app = new TimeLapse.App ();
        config = new TimeLapse.Config ();
    }

    private static int main (string[] args) {
        var main = new TimeLapse.Main ();

        return main.app.run (args);
    }
}
