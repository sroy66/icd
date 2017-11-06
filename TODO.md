# TODO

* Add read\_num method to Repository as
  > `public virtual GLib.SList<T> read\_num (int n, int offset, bool exclude\_blobs = true)`
* Validate job remaining/counter for progress
* Fix crashing on no camera connected (happens in Job currently?)
* Make the job continue on restart if not finished
* Review the RAML spec to make sure we're not deviating too far
* Create a job Queue (?)
* Add GUdev to (model?) to register camera connection changes (see udev.vala)
  to the model as CameraRepository
* Create database entry in table on camera connect
* Delete database entry in table on camera disconnect

## GUdev notes for CameraRepository

```
public class Icd.Model : ... {

    ...
    public CameraRepository cameras { get; construct set; }
    ...
    public void init () {
        ...
        cameras = new CameraRepository (db);
        ...
    }
    ...
}

public class CameraRepository : Repository<Icd.Camera?> {

    public () {
        base (db);
        name = "cameras";
        // do the udev stuff
        udev.uevent.connect (connection_cb);
    }

    private connection_cb () {
        if (evt == add) {
            var cam = new Camera ();
            cam.initialize ();
            // fill in cam ?
            create (cam);
        } else if (evt == remove) {
            list = read_all ();
            for (cam in list) {
                if (cam.devname == evt.get("DEVNAME") {
                    delete (cam.id);
                }
            }
        }
    }
}
```
