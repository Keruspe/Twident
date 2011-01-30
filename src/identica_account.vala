using TwidentEnums;
using Gee;

namespace Identica {

public class Account : Twitter.Account {
	
	//public string s_login {get; set; default = "";}
	//public string s_password {get; set; default = "";}
	protected override string consumer_key {get; set; default = "d86a9a9bac8c07e58f922d0dd2a1ceb3";}
	protected override string consumer_secret {get; set; default = "0d33c54fca5a3481e0a0968d2c2326c2";}
	
	public override string id {get; set; default = "identica";}
	
	protected override string root_url {get; set; default = "http://identi.ca/api/";}
	protected override string search_url {get; set; default = "http://identi.ca/api/";}
	
	construct {
		//base;
		//avaliable_streams.set(StreamEnum.GROUP, typeof(Identica.StreamGroup));
	}
	
	protected override void init_stream(AStream stream) {
		if(stream.get_type() == typeof(Identica.StreamGroup)) { //init group stream
			if(((StreamGroup) stream).s_group_name == "") {
				SearchDialog s_dialog = new SearchDialog();
				if(s_dialog.run() == Gtk.ResponseType.OK) {
					((StreamGroup) stream).s_group_name = s_dialog.input.get_text();
					s_dialog.close();
					((Twitter.StreamAbstract) stream).set_proxy(proxy, s_name);
				} else { //remove stream
					int index = streams.index_of(stream);
					streams_actions_tracker(index, MenuItems.REMOVE);
					s_dialog.close();
					return;
				}
				return;
			}
		}
		
		base.init_stream(stream);
	}
	
	protected override HashMap<StreamEnum, GLib.Type> avaliable_streams() {
		HashMap<StreamEnum, GLib.Type> map = base.avaliable_streams();
		map.set(StreamEnum.GROUP, typeof(Identica.StreamGroup));
		return map;
	}
	
	public override void go_group(string group_name) {
		HashMap<string, string> map = new HashMap<string, string>();
		map["s-group-name"] = group_name;
		
		debug(avaliable_streams().size.to_string());
		add_stream(StreamEnum.GROUP, true, map);
	}
	
	//private Rest.Proxy proxy;
	/*
	protected override void init_stream(AStream stream) {
		debug("init stream");
		
		if(s_password == "")
			return;
		
		if(stream.get_type().name() == "TwitterStreamSearch") { //setup searches
			if(((Twitter.StreamSearch) stream).s_keyword == "") {
				SearchDialog s_dialog = new SearchDialog();
				if(s_dialog.run() == Gtk.ResponseType.OK) {
					((Twitter.StreamSearch) stream).s_keyword = s_dialog.input.get_text();
					s_dialog.close();
				} else { //remove stream
					int index = streams.index_of(stream);
					streams_actions_tracker(index, MenuItems.REMOVE);
					s_dialog.close();
					return;
				}
			}
		}
		
		Rest.Proxy search_proxy = new Rest.Proxy("http://identi.ca/api/", false);
		((Twitter.StreamAbstract) stream).set_proxy(proxy, s_name, s_password);
	}
	
	public override void post_install() {
		debug("new proxy");
		//create proxy
		if(proxy == null) {
			debug("new proxy");
			proxy = new Rest.Proxy("http://identi.ca/api/", false);
		}
		
		//load userpic
		load_userpic_thread();
		
		//setp proxies to all streams
		foreach(AStream stream in streams) {
			init_stream(stream);
		}
	}
	
	public override bool create(Gtk.Window w) {
		debug("trying to create account");
		
		CreateDialog create_dlg = new CreateDialog(w);
		if(create_dlg.run() == Gtk.ResponseType.OK) {
			setup_default_streams();
			
			s_password = create_dlg.s_password;
			s_name = create_dlg.user.name;
			s_avatar_url = create_dlg.user.pic;
			
			load_userpic_thread();
			
			create_dlg.close();
			
			proxy = new Rest.Proxy("http://identi.ca/api/", false);
			
			return true;
		}
		
		create_dlg.close();
		return false;
	}
	
	protected override void set_sec_params(Rest.ProxyCall call) {
		uchar[] b_chars = Utils.string_to_uchar_array("%s:%s".printf(s_name, s_password));
		string http_auth = GLib.Base64.encode(b_chars);
		call.add_header("Authorization", "Basic %s".printf(http_auth));
		
		call.add_param("source", Config.APPNAME);
	}
	*/
}

}
