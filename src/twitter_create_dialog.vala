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
	
	private weak Thread<void*>? request_token_thread = null;
	private bool must_close = false;
	private OAuthProxy proxy;
	
	private string root_url {get; set; default = "";}
	public string s_token;
	public string s_token_secret;
	public string s_name;
	public string s_avatar_url;
	
	public CreateDialog(Window parent, string root_url, string consumer_key,
		string consumer_secret, string icon_name, string service_name) {
		
		base(parent, _("Link with %s account").printf(service_name), icon_name);
		
		debug(this.root_url);
		this.root_url = root_url;
		debug("ok");
		
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
		acc_img = new Image();
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
			must_close = true;
			proxy.dispose();
		});
	}
	
	private void request_token_action() {
		auth_btn.set_sensitive(false);
		tprogress.show();
		tprogress.start();
		
		try {
			request_token_thread = Thread.create<void*>(request_token, true);
			//jo = request_token_thread.join();
		} catch(ThreadError e) {
			debug(e.message);
		}
	}
	
	private void access_token_action() {
		access_btn.set_sensitive(false);
		pin.set_sensitive(false);
		
		try {
			request_token_thread = Thread.create<void*>(access_token, true);
		} catch(ThreadError e) {
			debug(e.message);
		}
	}
	
	private void* request_token() {
		bool answer = false;
		try {
			answer = OAuthProxy.request_token(proxy, "oauth/request_token", "oob");
		} catch (GLib.Error e) {
			debug(e.message); //TODO
		}
		
		if(!answer) {
			debug("request token is failed");
			
			if(must_close)
				return null;
			
			auth_btn.set_sensitive(true);
			tprogress.hide();
			return null;
		}
		
		if(must_close)
			return null;
		
		Idle.add(() => {
			string token = OAuthProxy.get_token(proxy);
			token_received(token);
			return false;
		});
		
		return null;
	}
	
	private void* access_token() {
		bool answer = false;
		
		try {
			answer = OAuthProxy.access_token(proxy, "oauth/access_token", pin.text);
		} catch(GLib.Error e) {
			debug(e.message); //TODO
		}
		
		if(!answer) {
			debug("access token is failed");
			
			return if_error();
		}
		
		if(must_close)
			return null;
		
		//fetching credentioals
		Rest.ProxyCall call = proxy.new_call();
		call.set_function("account/verify_credentials.xml");
		call.set_method("GET");
		
		try {
			answer = call.sync();
		} catch(GLib.Error e) {
			debug(e.message); //TODO
			
			return if_error();
		}
		
		if(!answer) {
			debug("access token is failed");
			
			return if_error();
		}
		
		debug(call.get_payload());
		
		Rest.XmlParser parser = new Rest.XmlParser();
		Rest.XmlNode root = parser.parse_from_data(call.get_payload(),
			(int64) call.get_payload().length);
		
		foreach(var val in root.children.get_values()) {
			Rest.XmlNode node = (Rest.XmlNode) val;
			if(node.name == "profile_image_url") {
				this.s_avatar_url = node.content;
				string? acc_img_path = img_cache.download(node.content);
				if(acc_img_path != null)
					acc_img.set_from_file(acc_img_path);
			}
			
			if(node.name == "screen_name") {
				this.s_name = node.content;
				acc_name.set_markup(_("Hello, <b>%s</b>!\nPress 'OK' to add this account".printf(node.content)));
			}
		}
		
		if(must_close)
			return null;
		
		acc_info.show();
		
		Idle.add(() => {
			this.s_token = OAuthProxy.get_token(proxy);
			this.s_token_secret = OAuthProxy.get_token_secret(proxy);
			
			ok_btn.set_sensitive(true);
			
			return false;
		});
				
		return null;
	}
	
	/* When we got a token */
	private void token_received(string token) {
		debug(token);
		
		//open link in a browser
		GLib.Pid pid;
		
		try {
			GLib.Process.spawn_async(".", {"/usr/bin/xdg-open",
				root_url + "oauth/authorize?oauth_token=" + token}, null,
				GLib.SpawnFlags.STDOUT_TO_DEV_NULL, null, out pid);
		} catch(GLib.SpawnError e) {
			debug(e.message); //TODO
		}
		
		tprogress.hide();
		pin_info.show();
		a_box.show();
		
		set_focus(pin);
	}
	
	private void* if_error() {
		if(must_close)
			return null;
		
		access_btn.set_sensitive(true);
		pin.set_sensitive(true);
		return null;
	}
}

}
