using Gtk;

public class CreateDialogGeneric : Gtk.Dialog {
	
	protected InfoBar pin_info;
	protected Avatar acc_img;
	protected Label acc_name;
	
	protected Button ok_btn;
	
	public CreateDialogGeneric(Window parent, string title, string icon_path) {
		set_transient_for(parent);
		set_modal(true);
		set_has_separator(false);
		set_size_request(300, 300);
		set_title(title);
		
		InfoBar info = new InfoBar();
		Image info_icon = new Image.from_file(icon_path);
		info_icon.set_alignment(0, 0);
		Label info_title = new Label("");
		info_title.set_markup("<b>%s</b>".printf(title));
		info.pack_start(info_icon, false, false, 10);
		info.pack_start(info_title, true, true, 10);
		info.reorder_child(info_icon, 0);
		info.reorder_child(info_title, 1);
		
		vbox.set_spacing(2);
		vbox.pack_start(info, false, false, 0);
		
		add_button(Stock.CANCEL, ResponseType.CANCEL);
		ok_btn = (Button) add_button(Stock.OK, ResponseType.OK);
		ok_btn.set_sensitive(false);
	}
}
