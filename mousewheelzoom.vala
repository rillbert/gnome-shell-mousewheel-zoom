// gnome-shell-mousewheel-zoom

// (c) Mar 2012, Tobias Quinn <tobias@tobiasquinn.com>
// GPLv3

using X;
using GLib;

const int MOUSEWHEEL_UP   = 4;
const int MOUSEWHEEL_DOWN = 5;

const int[] BUTTONS = { MOUSEWHEEL_UP, MOUSEWHEEL_DOWN };

[DBus (name = "org.gnome.Magnifier")]
interface Magnifier : Object {
    public abstract bool isActive() throws IOError;
    public abstract GLib.ObjectPath[] getZoomRegions() throws IOError;
}

[DBus (name = "org.gnome.Magnifier.ZoomRegion")]
interface ZoomRegion : Object {
    public abstract void setMagFactor(double xMagFactor, double yMagFactor) throws IOError;
    public abstract double getMagFactor() throws IOError;
}

class Zoomer : GLib.Object {
// DBus proxy objects
    private Magnifier mag;
    private ZoomRegion zoom;

// Zoom state
    private const double incr = 0.1;
    private double current_zoom;
    private bool zoom_active;

    public Zoomer() {
        mag = Bus.get_proxy_sync(BusType.SESSION,
                "org.gnome.Magnifier",
                "/org/gnome/Magnifier");
        // refresh zoom regions (exposes ZoomRegion interface)
        mag.getZoomRegions();
        zoom = Bus.get_proxy_sync(BusType.SESSION,
                "org.gnome.Magnifier",
                "/org/gnome/Magnifier/ZoomRegion/zoomer0");
        // get current zoom state
        zoom_active = mag.isActive();
        current_zoom = zoom.getMagFactor();
        stdout.printf("ACTIVE %s\n", zoom_active ? "Yes" : "No");
        stdout.printf("ZOOM %f\n", current_zoom);
    }

    public void zoomIn() {
        stdout.printf("ZI\n");
    }

    public void zoomOut() {
        stdout.printf("ZOUT\n");
    }
}

void main(string[] arg) {
    X.Display disp = new X.Display();
    X.Window root = disp.default_root_window();
    foreach (int button in BUTTONS) {
        disp.grab_button(button,
                X.KeyMask.Mod2Mask | X.KeyMask.Mod1Mask,
                root,
                false,
                0,
                X.GrabMode.Async,
                X.GrabMode.Async,
                0,
                0);
    }

    X.Event evt = Event();
    Zoomer zoom = new Zoomer();
    return;
    while (true) {
        disp.next_event(ref evt);
        switch(evt.xbutton.button) {
            case MOUSEWHEEL_UP:
                zoom.zoomIn();
                break;

            case MOUSEWHEEL_DOWN:
                zoom.zoomOut();
                break;

            default:
                stdout.printf("uncaught event\n");
                break;
        }
    }
}
