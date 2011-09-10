/** Interface for widgets, which needs to be redrawn */
public interface Redrawable : Gtk.Widget {
	protected void redraw() {
		if (null == this.window)
			return;

		unowned Gdk.Region region = this.window.get_clip_region ();
		this.window.invalidate_region (region, true);
		this.window.process_updates (true);
    }
}

