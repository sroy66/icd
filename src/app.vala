public class TimeLapse.App : GLib.Object {

    private TimeLapse.Router router;
    private VSGI.Server server;

    public App () {
        router = new TimeLapse.Router ();
        server = VSGI.Server.@new ("http", handler: router);
    }

    public int run (string[] args) {
        string address = "127.0.0.1";
        int port = 3003;

        var config = TimeLapse.Config.get_default ();

        if (config.is_loaded) {
            try {
                address = config.get_address ();
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("An address wasn't provided, using default '%s'", address);
                }
            }

            try {
                port = config.get_port ();
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A port wasn't provided, using default of '%d'", port);
                }
            }
        }

        var bind = "%s:%d".printf (address, port);
        string[] _args = { "tl", "--address", bind };
        return server.run (_args);
    }
}
