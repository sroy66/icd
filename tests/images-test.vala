using Valum;
using VSGI.Mock;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/api/images", () => {
		var router = new TimeLapse.ImageRouter ();
        /*
		 *router.get ("/api/images", (req, res) => {
         *    return true;
         *});
         */

		var req = new Request.with_uri (new Soup.URI ("http://localhost/api/images"));
		var res = new Response (req);

        try {
            assert (router.handle (req, res));
        } catch (GLib.Error e) {
            assert_not_reached ();
        }
	});

    return Test.run ();
}
