using Valum;

public class TimeLapse.Router : Valum.Router {

    construct {
        rule (Method.GET,       "/",                        route_index_cb);
        rule (Method.GET,       "/static/<path:path>",      route_static_cb);

        rule (Method.GET,               "/image",           route_view_image_cb);
        rule (Method.GET | Method.POST, "/image/<int:id>",  route_edit_image_cb);
    }

    private bool route_index_cb (VSGI.Request req, VSGI.Response res) {
        return res.expand_utf8 ("Hello world!");
    }

    private bool route_static_cb () {
        return Valum.Static.serve_from_resource (Resource.load ("resource"), "/static/");
    }

    private bool route_view_image_cb (VSGI.Request req, VSGI.Response res) {
        return true;
    }

    private bool route_edit_image_cb (VSGI.Request req, VSGI.Response res) {
        return true;
    }
}
