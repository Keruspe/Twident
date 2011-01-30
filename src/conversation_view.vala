using Gtk;

public class ConversationView : HBox {
	
	private VBox vbox;
	private EventBox spacer;
	
	public ConversationView() {
		GLib.Object(homogeneous: false, spacing: 0);
		spacer = new EventBox();
		spacer.set_size_request(20, 10);
		vbox = new VBox(false, 2);
		pack_start(spacer, false, false, 0);
		pack_start(vbox, true, true, 0);
	}
	
	public void add_delegate(StatusDelegate d) {
		vbox.pack_start(d, true, true, 0);
		d.show_all();
	}
}
