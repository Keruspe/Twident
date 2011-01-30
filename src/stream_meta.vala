using TwidentEnums;

public class StreamMeta : Object {

	public string name {get; set;}
	public Gdk.Pixbuf icon {get; set;}

	public StreamMeta(string name, Gdk.Pixbuf icon) {
		this.name = name;
		this.icon = icon;
	}

	/** Return image special for application menus */
	public Gtk.Image get_menu_image() {
		return new Gtk.Image.from_pixbuf(icon.scale_simple(16,
			16, Gdk.InterpType.TILES));
	}

	/** Return pixbuf special for tree widget */
	public Gdk.Pixbuf get_tree_pixbuf() {
		return icon.scale_simple(24, 24, Gdk.InterpType.TILES);
	}
}
