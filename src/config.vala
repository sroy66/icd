/**
 * A complete configuration file may contain:
 *
 * {{{
 * [general]
 * address = 127.0.0.1
 * port = 3003
 *
 * [database]
 * host = 127.0.0.1
 * port = 3306
 * name = cis
 * provider = MySQL
 * username = bob
 * password = nonsense
 * }}}
 */
public class Icd.Config : GLib.Object {

    private GLib.KeyFile file;
    private static Once<Icd.Config> _instance;

    /* [general] backing fields */
    private string address = "127.0.0.1";
    private int port = 3003;

    /* [database] backing fields */
    private string db_host = "127.0.0.1";
    private int db_port = 3306;
    private string db_name = Environment.get_application_name ();
    private string db_provider = "SQLite";
    private string db_path = ".";
    private string? db_username = null;
    private string? db_password = null;
    private string? db_dsn = null;
    private bool db_reset = false;

    public bool is_loaded { get; private set; default = false; }

    /**
     * @return Singleton for the Config class
     */
    public static unowned Icd.Config get_default () {
        return _instance.once (() => { return new Icd.Config (); });
    }

    public void load_from_file (string filename) throws GLib.Error {
        is_loaded = true;
        file = new GLib.KeyFile ();
        try {
            file.load_from_file (filename, KeyFileFlags.NONE);
        } catch (GLib.Error e) {
            is_loaded = false;
            throw e;
        }
    }

    public string get_address () throws GLib.Error {
        if (is_loaded) {
            try {
                address = file.get_string ("general", "address");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("An address wasn't configured, using default '%s'", address);
                } else {
                    throw e;
                }
            }
        }

        return address;
    }

    public int get_port () throws GLib.Error {
        if (is_loaded) {
            try {
                port = file.get_integer ("general", "port");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A port wasn't configured, using default '%d'", port);
                } else {
                    throw e;
                }
            }
        }

        return port;
    }

    public string get_db_host () throws GLib.Error {
        if (is_loaded) {
            try {
                db_host = file.get_string ("database", "host");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database host wasn't configured, using default '%s'", db_host);
                } else {
                    throw e;
                }
            }
        }

        return db_host;
    }

    public int get_db_port () throws GLib.Error {
        if (is_loaded) {
            try {
                db_port = file.get_integer ("database", "port");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database port wasn't configured, using default '%d'", db_port);
                } else {
                    throw e;
                }
            }
        }

        return db_port;
    }

    public string get_db_name () throws GLib.Error {
        if (is_loaded) {
            try {
                db_name = file.get_string ("database", "name");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database name wasn't configured, using default '%s'", db_name);
                } else {
                    throw e;
                }
            }
        }

        return db_name;
    }

    public string get_db_provider () throws GLib.Error {
        if (is_loaded) {
            try {
                db_provider = file.get_string ("database", "provider");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database provider wasn't configured, using default '%s'", db_provider);
                } else {
                    throw e;
                }
            }
        }

        return db_provider;
    }

    public string get_db_path () throws GLib.Error {
        if (is_loaded) {
            try {
                db_path = file.get_string ("database", "path");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database path wasn't configured, using default '%s'", db_path);
                } else {
                    throw e;
                }
            }
        }

        return db_path;
    }

    public string? get_db_username () throws GLib.Error {
        if (is_loaded) {
            try {
                db_username = file.get_string ("database", "username");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database username wasn't configured");
                } else {
                    throw e;
                }
            }
        }

        return db_username;
    }

    public string? get_db_password () throws GLib.Error {
        if (is_loaded) {
            try {
                db_password = file.get_string ("database", "password");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database password wasn't configured");
                } else {
                    throw e;
                }
            }
        }

        return db_password;
    }

    public string? get_db_dsn () throws GLib.Error {
        if (is_loaded) {
            try {
                db_dsn = file.get_string ("database", "dsn");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database dsn wasn't configured");
                } else {
                    throw e;
                }
            }
        }

        return db_dsn;
    }

    public bool get_db_reset () throws GLib.Error {
        if (is_loaded) {
            try {
                db_reset = file.get_boolean ("database", "reset");
            } catch (GLib.Error e) {
                if (e is KeyFileError.KEY_NOT_FOUND ||
                    e is KeyFileError.GROUP_NOT_FOUND) {
                    debug ("A database reset wasn't configured, using existing contents");
                } else {
                    throw e;
                }
            }
        }

        return db_reset;
    }
}
