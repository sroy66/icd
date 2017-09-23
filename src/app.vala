public class TimeLapse.App : GLib.Object {

    private TimeLapse.Model model;
    private TimeLapse.Router router;
    private VSGI.Server server;

    public App () {
        model = new TimeLapse.Model ();
        model.init ();

        router = new TimeLapse.Router (model);
        server = VSGI.Server.@new ("http", handler: router);
    }

    public int run (string[] args) {
        var config = TimeLapse.Config.get_default ();
        string[] _args;

        try {
            var bind = "%s:%d".printf (config.get_address (), config.get_port ());
            _args = { "tl", "--address", bind };
        } catch (GLib.Error e) {
            error (e.message);
        }

        return server.run (_args);
    }
}
