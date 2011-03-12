using Gtk;
using Rest;

namespace Identica {

public class CreateDialog : CreateDialogGeneric {
	
	protected ProxyCall call;
	protected ProxyCallAsyncCallback callback;
	
	private Entry login;
	private Entry password;
	private Button check_btn;
	private Spinner cprogress;
	
	InfoBar acc_info;
	
	public string s_password;
	
	public User user;
	
	public CreateDialog(Window parent) {
		base(parent, _("Link with Identica account"),  Config.SERVICE_IDENTICA_ICON);
		
		login = new Entry();
		password = new Entry();
		
		check_btn = new Button();
		
		HBox pbox = new HBox(false, 0);
		Image cimg = new Image.from_stock(Gtk.Stock.DIALOG_AUTHENTICATION,
			IconSize.MENU);
		Label check_label = new Label("");
		check_label.set_markup(_("<i>%s</i>".printf("Verify credentials")));
		cprogress = new Spinner();
		pbox.pack_start(cimg, false, false, 0);
		pbox.pack_start(check_label, false, false, 0);
		pbox.pack_end(cprogress, false, true, 0);
		
		check_btn.add(pbox);
		check_btn.clicked.connect(verify_credentials);
		
		acc_info = new InfoBar();
		acc_img = new Image();
		acc_name = new Label(null);
		
		acc_info.pack_start(acc_img, false, false, 0);
		acc_info.pack_start(acc_name, true, true, 5);
		acc_info.reorder_child(acc_img, 0);
		acc_info.reorder_child(acc_name, 1);
		
		HigTable auth_table = new HigTable(_("Authentication"));
		auth_table.add_two_widgets(new Label(_("Login")), login);
		auth_table.add_two_widgets(new Label(_("Password")), password);
		auth_table.add_widget_wide(check_btn);
		auth_table.add_widget_wide(acc_info);
		
		vbox.pack_start(auth_table, false, false, 5);
		vbox.show_all();
		
		cprogress.hide();
		acc_info.hide();
		
		Rest.Proxy proxy = new Rest.Proxy("http://identi.ca/api/", false);
		callback = (ProxyCallAsyncCallback) get_response;
		
		call = proxy.new_call();
		call.set_function("account/verify_credentials.xml");
	}
	
	private void verify_credentials() {
		cprogress.show();
		cprogress.start();
		check_btn.set_sensitive(false);
		
		uchar[] b_chars = Utils.string_to_uchar_array("%s:%s".printf(login.get_text(),
			password.get_text()));
		string http_auth = GLib.Base64.encode(b_chars);
		call.remove_header("Authorization");
		call.add_header("Authorization", "Basic %s".printf(http_auth));
		
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	private void get_response() {
		cprogress.hide();
		cprogress.stop();
		check_btn.set_sensitive(true);
		
		if(call.get_status_code() != 200) { //if we got some error
			debug(call.get_status_message()); //TODO
			return;
		}
		debug(call.get_payload());
		
		/*try {
			thread = Thread.create(load_userpic, true);
		} catch(ThreadError e) {
			debug(e.message);
			return;
		}*/
		
		user = Twitter.Parser.get_single_user(call.get_payload());
		
		s_password = password.get_text();
		
		acc_info.show_all();
		acc_name.set_markup("Hello, <b>%s</b>!\nPress 'OK' to add this account".printf(user.name));
		
		string? path = img_cache.download(user.pic);
		if(path != null)
			acc_img.set_from_file(path);
		
		debug("%s, %s", user.name, user.pic);
		
		ok_btn.set_sensitive(true);
	}
}

}
