using Gtk;

public class MenuIndicator : MenuItem {
	
	private Label tlabel;
	private Spinner spin;
	private Window main_window;
	
	public MenuIndicator(Window main_window) {
		this.main_window = main_window;
		remove(get_child());
		
		tlabel = new Label("some text");
		spin = new Spinner();
		spin.show();
		tlabel.show();
		HBox hb = new HBox(false, 5);
		hb.pack_start(tlabel, false, false, 0);
		hb.pack_start(spin, false, false, 0);
		
		add(hb);
		right_justified = true;
	}
	
	public void add_queue(string text) {
		main_window.get_window().set_cursor(new Gdk.Cursor(Gdk.CursorType.WATCH));
		
		show_all();
		spin.start();
		tlabel.set_text(text);
	}
	
	public void hide_queue() {
		spin.stop();
		hide_all();
		
		main_window.get_window().set_cursor(null);
	}
}
