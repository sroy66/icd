public class TimeLapse.App : GLib.Object {

    private TimeLapse.Router router;
    private VSGI.Server server;

    public App () {
        router = new TimeLapse.Router ();
        server = VSGI.Server.@new ("http", handler: router);
    }

    public int run (string[] args) {
        return server.run (args);
    }
}
