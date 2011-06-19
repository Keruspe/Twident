using Gtk;
using RestCustom;

namespace Twitter {

public class CreateDialog : CreateDialogGeneric {
	
	private Button auth_btn;
	private Spinner tprogress;
	private HBox a_box;
	private Entry pin;
	private Button access_btn;
	private InfoBar acc_info;
	
	private OAuthProxy proxy;
	
	private string root_url {get; set; default = "";}
	private string consumer_key {get; set; default = "";}
	private string consumer_secret {get; set; default = "";}

	public string s_token;
	public string s_token_secret;
	public string s_name;
	public string s_avatar_url;
	
	public CreateDialog(Window parent, string root_url, string consumer_key,
		string consumer_secret, string icon_name, string service_name) {
		
		base(parent, _("Link with %s account").printf(service_name), icon_name);
		
		this.root_url = root_url;
                this.consumer_key = consumer_key;
                this.consumer_secret = consumer_secret;
		
		this.proxy = new OAuthProxy(consumer_key, consumer_secret,
			root_url, false);
		
		auth_btn = new Button();
		Image timg = new Image.from_stock(Gtk.Stock.DIALOG_AUTHENTICATION,
			IconSize.MENU);
		Label tlabel = new Label(null);
		tlabel.set_markup("<i>%s</i>".printf(_("Authenticate in %s").printf(service_name)));
		tprogress = new Spinner();//Image.from_animation(progress);
		HBox btn_box = new HBox(false, 5);
		btn_box.pack_start(timg, false, false, 0);
		btn_box.pack_start(tlabel, false, true, 0);
		btn_box.pack_end(tprogress, false, true, 0);
		auth_btn.add(btn_box);
		
		auth_btn.clicked.connect(request_token_action);
		
		pin_info = new InfoBar();
		Label info_label = new Label(null);
		info_label.set_markup(_("<b>%s</b>".printf("Now enter PIN code and press the button")));
		pin_info.pack_start(info_label, false, false, 0);
		pin_info.reorder_child(info_label, 0);
		
		pin = new Entry();
		access_btn = new Button.with_label(_("Validate"));
		a_box = new HBox(false, 0);
		a_box.pack_start(pin, true, true, 0);
		a_box.pack_start(access_btn, false, false, 0);
		
		access_btn.clicked.connect(access_token_action);
		
		acc_info = new InfoBar();
		acc_img = new Avatar(48);
		acc_name = new Label(null);
		//acc_name.wrap_mode = Pango.WrapMode.WORD;
		//acc_name.set_ellipsize(Pango.EllipsizeMode.END);
		acc_info.pack_start(acc_img, false, false, 0);
		acc_info.pack_start(acc_name, true, true, 5);
		acc_info.reorder_child(acc_img, 0);
		acc_info.reorder_child(acc_name, 1);
		//acc_info.remove(acc_info.get_children().nth_data(2));
		
		HigTable auth_table = new HigTable(_("Authentication"));
		auth_table.add_widget_wide(auth_btn);
		auth_table.add_widget_wide(pin_info);
		auth_table.add_widget_wide(a_box);
		auth_table.add_widget_wide(acc_info);
		
		
		vbox.pack_start(auth_table, false, false, 5);
		vbox.show_all();
		
		//hidding some widgets
		tprogress.hide();
		pin_info.hide();
		a_box.hide();
		acc_info.hide();
		
		destroy.connect(() => {
			this.proxy.dispose();
		});
	}
	
	private void request_token_action() {
		auth_btn.set_sensitive(false);
		tprogress.show();
		tprogress.start();
		
			OAuthProxyAuthCallback request_token_callback = request_token;
                        try {
                        OAuthProxy.request_token_async(proxy, "oauth/request_token", "oob",
                            request_token_callback, this);
                        } catch (GLib.Error e) {
                        }
	}
	
	private void access_token_action() {
		access_btn.set_sensitive(false);
		pin.set_sensitive(false);
	
                OAuthProxyAuthCallback access_token_callback = access_token;
                try {
                    OAuthProxy.access_token_async(proxy, "oauth/access_token", pin.text, access_token_callback, this);
                } catch (GLib.Error e) {}
	}
	
	public void request_token(OAuthProxy proxy, Error? error, GLib.Object? obj) {
                if (error != null) {
                    extra_exit();
                    return;
                }
	
                string token = OAuthProxy.get_token(this.proxy);
		//open link in a browser
		GLib.Pid pid;
	        string command = root_url + "oauth/authorize?oauth_token=" + token;	
		try {
			GLib.Process.spawn_async(".", {"/usr/bin/xdg-open", command}, null,
				GLib.SpawnFlags.STDOUT_TO_DEV_NULL, null, out pid);
		} catch(GLib.SpawnError e) {
		}
		
		tprogress.hide();
		pin_info.show();
		a_box.show();
		
		set_focus(pin);
	}
	
	private void access_token(OAuthProxy proxy, Error? error, GLib.Object? obj) {
                if (error != null) {
                    extra_exit();
                    return;
                }
                Rest.ProxyCall call = proxy.new_call();
		call.set_function("account/verify_credentials.xml");
		call.set_method("GET");
		
		Rest.ProxyCallAsyncCallback gc_callback = get_credentials;
		try {
                    call.run_async(gc_callback, this);
                } catch (GLib.Error e) {}
	}
	
	private void get_credentials(Rest.ProxyCall call, Error? error,
		GLib.Object? obj) {
		
		if(error != null) {
			extra_exit();
			return;
		}
		
		debug(call.get_payload());
		
		User? user = Twitter.Parser.get_single_user(call.get_payload());
		if(user == null) {
		extra_exit(_("Error when parsed credentials"));
		return;
		}
		
		this.s_avatar_url = user.pic;
		acc_img.set_from_url(user.pic);
		this.s_name = user.name;
		acc_name.set_markup(_("Hello, <b>%s</b>!\nPress <b>OK</b> to add this account".printf(user.name)));
		
		acc_info.show();
		
		this.s_token = OAuthProxy.get_token(proxy);
		this.s_token_secret = OAuthProxy.get_token_secret(proxy);
		
		ok_btn.set_sensitive(true);
	}
	
	void extra_exit(string msg =
		_("Something went wrong. You can't complete authorization.")) {
		
		MessageDialog dlg = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL,
			Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
			msg);
		
		dlg.run();
		dlg.close();
		
		response(ResponseType.CANCEL);
	}
}

}
