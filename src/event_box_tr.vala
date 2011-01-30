using Gtk;
using Cairo;

/** Class for event boxes with transparent background and 'hand' cursor on enter-motion event */
public class EventBoxTr : EventBox {
	
	public EventBoxTr() {
		GLib.Object();
		
		set_has_window(false);
		
		set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
		set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
		set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);
		
		enter_notify_event.connect((event) => {
			set_has_window(true);
			get_window().set_cursor(new Gdk.Cursor(Gdk.CursorType.HAND2));
			return true;
		});
		
		leave_notify_event.connect((event) => {
			get_window().set_cursor(null);
			set_has_window(false);
			return true;
		});
	}
}
