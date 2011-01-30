using Gtk;

public class SearchDialog : Dialog {
	
	public Entry input;
	public Button btn;
	
	public SearchDialog() {
		set_modal(true);
		set_has_separator(false);
		set_size_request(200, -1);
		
		input = new Entry();
		btn = new Button.with_label(_("Search"));
		btn.clicked.connect(() => {
			if(input.get_text().length < 2)
				return; //TODO
			
			response(ResponseType.OK);
		});
		
		HBox hbox = new HBox(false, 5);
		hbox.pack_start(input, true, true, 0);
		hbox.pack_start(btn, false, false, 0);
		
		vbox.pack_start(hbox, false, false, 5);
		
		set_default(btn);
		
		show_all();
	}
}
