using VSGI;
using Valum;
using Valum.ContentNegotiation;

public class Icd.JobRouter : Valum.Router {

    construct {
        once ((req, res, next) => {
            return next ();
        });

        rule (Method.GET,    "/(<int:id>)?", view_cb);
        rule (Method.PUT,    "/<int:id>",    accept ("application/json", edit_cb));
        rule (Method.POST,   "/",            accept ("application/json", create_cb));
        rule (Method.DELETE, "/(<int:id>)?", delete_cb);
    }

    private bool view_cb (Request req, Response res, NextCallback next, Context context)
                          throws GLib.Error {
        var id = context["id"];
        var model = Icd.Model.get_default ();
        if (id == null) {
            var jobs = model.jobs.read_all ();
            var generator = new Json.Generator ();
            if (jobs.length () > 0) {
                res.headers.set_content_type ("application/json", null);
                var job_array = new Json.Array ();
                foreach (var job in jobs) {
                    job_array.add_element (Json.gobject_serialize (job));
                }
                var node = new Json.Node.alloc ();
                node.init_array (job_array);
                generator.set_root (node);
                return generator.to_stream (res.body);
            } else {
                /* FIXME Need to return a proper code in the response */
                throw new ClientError.NOT_FOUND (
                    "No jobs were found");
            }
        } else {
            var job = model.jobs.read (int.parse (id.get_string ()));
            var generator = new Json.Generator ();
            if (job != null) {
                res.headers.set_content_type ("application/json", null);
                generator.root = Json.gobject_serialize (job);
                generator.pretty = false;
                return generator.to_stream (res.body);
            } else {
                /* FIXME Need to return a proper code in the response */
                throw new ClientError.NOT_FOUND (
                    "No job was found with the ID provided");
            }
        }
    }

    private bool edit_cb (Request req, Response res, NextCallback next, Context context, string content_type)
                          throws GLib.Error {
        var id = context["id"];
        if (id == null) {
            throw new ClientError.NOT_FOUND ("No job ID was provided");
        }

        switch (content_type) {
            case "application/json":
                try {
                    var model = Icd.Model.get_default ();
                    var job = model.jobs.read (int.parse (id.get_string ()));
                    var parser = new Json.Parser ();
                    parser.load_from_stream (req.body);
                    var node = parser.get_root ();
                    var obj = node.get_object ();
                    obj.foreach_member ((prop, name, prop_node) => {
                        ((Object) job).set_property (name, prop_node.get_value ());
                    });

                    model.jobs.update (job);
                } catch (GLib.Error e) {
                    throw new ClientError.BAD_REQUEST (
                        "Invalid or malformed JSON was provided");
                }
                break;
            default:
                throw new ClientError.BAD_REQUEST (
                    "Request used incorrect content type, 'application/json' expected");
        }
        return res.end ();
    }

    private bool create_cb (Request req, Response res, NextCallback next, Context context, string content_type)
                            throws GLib.Error {

        switch (content_type) {
            case "application/json":
                try {
                    var parser = new Json.Parser ();
                    parser.load_from_stream (req.body);
                    /*debug (Json.to_string (parser.get_root (), true));*/
                    Icd.Job job = Json.gobject_deserialize (typeof (Icd.Job),
                                                parser.get_root ()) as Icd.Job;
                    /*debug ("id: %d count: %d interval: %d", job.id, job.count, job.interval);*/
                    var model = Icd.Model.get_default ();
                    job.id = model.jobs.create (job);
					job.run.begin ();
                } catch (GLib.Error e) {
                    throw new ClientError.BAD_REQUEST (
                        "Invalid or malformed JSON was provided");
                }
                break;
            default:
                throw new ClientError.BAD_REQUEST (
                    "Request used incorrect content type, 'application/json' expected");
        }

        res.headers.set_content_type ("image/png", null);

        return res.end ();
    }

    private bool delete_cb (Request req, Response res, NextCallback next, Context context)
                            throws GLib.Error{
        var id = context["id"];
        var model = Icd.Model.get_default ();
        if (id != null) {
            model.jobs.delete (int.parse (id.get_string ()));
        } else {
            model.jobs.delete_all ();
        }

        return res.end ();
    }
}
