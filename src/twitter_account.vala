using Gee;
using TwidentEnums;
using RestCustom;

namespace Twitter {

public class Account : AAccount {
	
	protected virtual string consumer_key {get; set; default = "DbGeqiAS0U3r4a5U5zFg";}
	protected virtual string consumer_secret {get; set; default = "uYhZKGAvtzyYzGl6KsjTpJ6kdNzDKG8r1dcpoQGVV4";}
	protected Rest.Proxy proxy;
	
	protected virtual string root_url {get; set; default = "http://twitter.com/";}
	protected virtual string search_url {get; set; default = "http://search.twitter.com/";}
	
	//protected virtual string service_icon {get; set; default = accounts_types[get_type()].name}
	//protected virtual string service_icon {get; set; default = "Twitter";}
	
	public string s_token {get; set; default = "";}
	public string s_token_secret {get; set; default = "";}

	public override MenuItems[] popup_items {
		owned get {
			return {
				MenuItems.SETTINGS,
				MenuItems.REMOVE
			};
		}
	}
	
	public override StatusMenuItems[] status_popup_items {
		owned get {
			return {
				StatusMenuItems.REPLY,
				StatusMenuItems.RETWEET,
				StatusMenuItems.FAVORITE,
				StatusMenuItems.REMOVE
			};
		}
	}
	
	protected override HashMap<StreamEnum, GLib.Type> avaliable_streams() {
			HashMap<StreamEnum, GLib.Type> map = new HashMap<StreamEnum, GLib.Type>();

			map.set(StreamEnum.HOME, typeof(Twitter.StreamHome));
			map.set(StreamEnum.MENTIONS, typeof(Twitter.StreamMentions));
			map.set(StreamEnum.PUBLIC, typeof(Twitter.StreamPublic));
			map.set(StreamEnum.FAVORITES, typeof(Twitter.StreamFavorites));
			map.set(StreamEnum.SEARCH, typeof(Twitter.StreamSearch));
			return map;
		
	}
	
	protected override StreamEnum[] default_streams {
		owned get {
			return {
				StreamEnum.HOME,
				StreamEnum.MENTIONS
			};
		}
	}
	
	protected RecursiveReply rec_reply;
	
	construct {
	}
	
	public override string id {get; set; default = "twitter";}
	
	protected override void init_stream(AStream stream) {
		
		if(s_token != "") {
			if(stream.get_type().name() == "TwitterStreamSearch") { //setup searches
				if(((StreamSearch) stream).s_keyword == "") {
					SearchDialog s_dialog = new SearchDialog();
					if(s_dialog.run() == Gtk.ResponseType.OK) {
						((StreamSearch) stream).s_keyword = s_dialog.input.get_text();
						s_dialog.close();
					} else { //remove stream
						int index = streams.index_of(stream);
						streams_actions_tracker(index, MenuItems.REMOVE);
						s_dialog.close();
						return;
					}
				}
				
				Rest.Proxy search_proxy = new Rest.Proxy(search_url, false);
				((Twitter.StreamAbstract) stream).set_proxy(search_proxy, s_name);
			} else {
				((Twitter.StreamAbstract) stream).set_proxy(proxy, s_name);
			}
		}
	}
	
	public override void post_install() {
		//create proxy
		if(s_token != "") {
			proxy = new OAuthProxy.with_token(consumer_key, consumer_secret,
				s_token, s_token_secret, root_url, false);
		}
		
		//load userpic
		load_userpic_thread();
		
		//setp proxies to all streams
		foreach(AStream stream in streams) {
			init_stream(stream);
		}
	}
	
	public override bool create(Gtk.Window w) {
		CreateDialog create_dlg = new CreateDialog(w, root_url, consumer_key,
			consumer_secret, accounts_types[get_type()].icon_name,
			accounts_types[get_type()].name);
		
		if(create_dlg.run() == Gtk.ResponseType.OK) {
			base.create(w);
			
			s_token = create_dlg.s_token;
			s_token_secret = create_dlg.s_token_secret;
			s_name = create_dlg.s_name;
			s_avatar_url = create_dlg.s_avatar_url;
			
			load_userpic_thread();
			
			create_dlg.close();
			
			proxy = new OAuthProxy.with_token(consumer_key, consumer_secret,
				s_token, s_token_secret, root_url, false);
			
			return true;
		}
		
		create_dlg.close();
		return false;
	}
	
	public override AStream? new_content_action(string action_type,
		string stream_hash, string val) {
		
		switch(action_type) {
		case "search":
			HashMap<string, string> map = new HashMap<string, string>();
			map["s-keyword"] = "#" + val;
			add_stream(StreamEnum.SEARCH, true, map);
			return null;
		
		/*
		case "reply":
			Status? status = null;
			foreach(AStream stream in streams) {
				if(get_stream_hash(stream) == stream_hash) {
					status = get_status(stream.stream_type, val);
				}
			}
			
			if(status != null)
				menu_do_reply(status);
			break;
		*/
		/*
		case "context":
			Status? status = null;
			foreach(AStream stream in streams) {
				if(get_stream_hash(stream) == stream_hash) {
					status = get_status(stream.stream_type, val);
					break;
				}
			}
			
			if(status == null)
				return null;
			
			
			//get status and send signal to cintent_view
			rec_reply = new RecursiveReply(proxy, status, s_name,
				stream_hash);
			rec_reply.new_reply.connect((rstatus, shash, sid) => {
				insert_reply(shash, sid, rstatus); //signal
			});
			rec_reply.run();
			
			break;
		*/
		/*
		case "contextmenu":
			AStream? stream = null;
			Status? status = null;
			foreach(AStream astream in streams) {
				if(get_stream_hash(astream) == stream_hash) {
					stream = astream;
					
					foreach(Status astatus in stream.statuses_fresh) {
						if(astatus.id == val) {
							status = astatus;
							break;
						}
					}
					if(status == null) {
						foreach(Status astatus in stream.statuses) {
							if(astatus.id == val) {
								status = astatus;
								break;
							}
						}
					}
					break;
				}
			}
			
			if(stream != null && status != null)
				context_menu(stream, status);
			else
			
			return null;
		*/
		}
		
		return null;
	}
	
	public override void get_conversation(Status status) {
		
		//get status and send signal to cintent_view
		rec_reply = new RecursiveReply(proxy, status, s_name);
		/*
		rec_reply.new_reply.connect((rstatus, sid) => {
			//insert_reply(shash, sid, rstatus); //signal
		});*/
		rec_reply.run();
	}
	
	public override void go_hashtag(string tag) {
		HashMap<string, string> map = new HashMap<string, string>();
		map["s-keyword"] = "#" + tag;
		add_stream(StreamEnum.SEARCH, true, map);
	}
	
	protected void load_userpic_thread() {
		try {
			Thread.create<void*>(load_userpic, true);
		} catch(GLib.Error e) {
		}
	}
	
	private void* load_userpic() {
		if(s_avatar_url == "")
			Thread.usleep(5000);
		
		string? img_path = img_cache.download(s_avatar_url);
		if(img_path != null) {
			Idle.add(() => {
				try {
					userpic = new Gdk.Pixbuf.from_file(img_path);
				} catch(GLib.Error e) {
				}
				return false;
			});
		}
		
		return null;
	}
	
	public override void send_status(string status_text, string reply_id) {
		
		Rest.ProxyCall call = proxy.new_call();
		call.add_param("status", status_text);
		
		if(reply_id != "")
			call.add_param("in_reply_to_status_id", reply_id);
		
		call.set_function("statuses/update.xml");
		call.set_method("POST");
		
		Rest.ProxyCallAsyncCallback callback = status_sent_respose;
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	protected void status_sent_respose(Rest.ProxyCall call, Error? error, Object? obj) {
		
		status_sent(this, true);
		
		foreach(AStream stream in streams) {
			if(stream.stream_type == StreamEnum.HOME) {
				((StreamAbstract) stream).sync();
				break;
			}
		}
	}
	
	protected override void menu_do_favorite(Status status) {
		Rest.ProxyCall call = proxy.new_call();
		call.set_method("POST");
		
		if(status.favorited) {
			message_indicate(_("Removing from favorites...")); //signal
			call.set_function("favorites/destroy/%s.xml".printf(status.id));
		}
		else {
			message_indicate(_("Adding to favorites...")); //signal
			call.set_function("favorites/create/%s.xml".printf(status.id));
		}
		
		Rest.ProxyCallAsyncCallback callback = ((c, e, o) => {
			if(c.get_status_code() == 200) {
				Status fstatus = Twitter.Parser.get_status_from_string(c.get_payload(),
					s_name);
				
				if(fstatus != null) {
					foreach(Status real_status in get_statuses(fstatus.id)) {
						if(real_status != null) {
							real_status.favorited = !real_status.favorited;
						}
					}
				}
			}
			
			stop_indicate(); //signal
		});
		
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	protected override void menu_do_retweet(Status status) {
		Rest.ProxyCall call = proxy.new_call();
		call.set_method("POST");
		
		message_indicate(_("Making retweet...")); //signal
		
		call.set_function("statuses/retweet/%s.xml".printf(status.id));
		
		Rest.ProxyCallAsyncCallback callback = ((c, e, o) => {
			if(c.get_status_code() != 200) {
				//TODO
			}
			
			stop_indicate(); //signal
		});
		
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	protected override void menu_do_remove(Status status) {
		Rest.ProxyCall call = proxy.new_call();
		call.set_method("POST");
		
		message_indicate(_("Removing status...")); //signal
		
		call.set_function("statuses/destroy/%s.xml".printf(status.id));
		
		Rest.ProxyCallAsyncCallback callback = ((c, e, o) => {
			if(c.get_status_code() != 200) {
				//TODO
				return;
			}
			
			Status fstatus = Twitter.Parser.get_status_from_string(c.get_payload(),
					s_name);
			
			if(fstatus != null) {
				remove_status_complete(fstatus.id);
			}
			
			stop_indicate(); //signal
		});
		
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	protected override void menu_do_reply(Status status) {
		if(!status.own)
			do_reply(this, status); //signal
	}
}

}
