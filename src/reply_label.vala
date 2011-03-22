using Gtk;

public class ReplyLabel : HBox {
	
	private Label label;
	private Image img;
	private HBox hb;
	private EventBoxTr ebox;
	private Spinner? progress = null;
	
	public signal void clicked();
	
	public ReplyLabel(string username) {
		GLib.Object(homogeneous: false, spacing: 0);
		
		ebox = new EventBoxTr();
		hb = new HBox(false, 0);
		
		img = new Image.from_file(Config.CONVERSATION_PATH);
		label = new Label(null);
		label.set_markup("<small><b><span foreground='#888'>%s </span>%s</b></small>".printf(_("in reply to"), username));
		
		hb.pack_start(img, false, false, 0);
		hb.pack_start(label, false, false, 4);
		
		ebox.add(hb);
		
		this.pack_start(ebox, false, false, 0);
		
		ebox.button_release_event.connect((event) => {
			if(event.button == 1)
				clicked(); //signal
			
			return true;
		});
	}
	
	public void set_tooltip(string text) {
		hb.set_tooltip_text(text);
	}
	
	public void start() {
		progress = new Spinner();
		progress.show();
		progress.start();
		hb.pack_start(progress, false, false, 0);
	}
	
	public void stop() {
		if(progress != null) {
			hb.remove(progress);
			//progress.expose();
			progress = null;
		}
	}
}
