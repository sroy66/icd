public class TimeLapse.Main : GLib.Object {

	public TimeLapse.App app;
    public TimeLapse.Config config;

    private static string? filename;

    private const GLib.OptionEntry[] options = {
        // --config FILENAME || -c FILENAME
        { "config", 'c', 0, OptionArg.FILENAME, ref filename, "Configuration file", null },
        { null }
    };

    private Main () {
        if (filename != null) {
            config = TimeLapse.Config.get_default ();
            try {
                config.load_from_file (filename);
                debug ("Bind to: %s:%d", config.get_address (), config.get_port ());
                debug ("DB host: %s:%d", config.get_db_host (), config.get_db_port ());
                debug ("DB name: %s", config.get_db_name ());
            } catch (GLib.Error e) {
                error (e.message);
            }
        }

        app = new TimeLapse.App ();
    }

    private static int main (string[] args) {
        try {
            var context = new OptionContext ("- Camera Interface Service");
            context.set_help_enabled (true);
            context.add_main_entries (options, null);
            context.parse (ref args);
        } catch (OptionError e) {
            critical (e.message);
            critical ("Run '%s --help' to see a list of options.", args[0]);
            return -1;
        }

        var main = new TimeLapse.Main ();

        return main.app.run (args);
    }
}
