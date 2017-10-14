public class Icd.App : GLib.Object {

    private Icd.Model model;
    private Icd.Router router;
    private VSGI.Server server;

    public App () {
        model = Icd.Model.get_default ();
        model.init ();

        router = new Icd.Router ();
        server = VSGI.Server.@new ("http", handler: router);
    }

    public int run (string[] args) {
        var config = Icd.Config.get_default ();
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
