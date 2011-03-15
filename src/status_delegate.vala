using Gtk;
using Cairo;
using Gee;

/** Separate class for status */
public class StatusDelegate : EventBox {
	
	private Status? status = null;
	private AStream? stream = null;
	
	private VBox vb_main;
	private BgBox hb_main;
	
	private Avatar avatar;
	private Label nick;
	private Label date;
	private WrapLabel content;
	private ReplyLabel re_label;
	private ConversationView? con_view = null;
	private VBox vb_right;
	private HBox hb_thumbs;
	
	private SmartTimer timer;
	
	private Gdk.Pixbuf? rt_pixbuf = null;
	
	private string date_string = "<small><span foreground='#888'><b>%s</b></span></small>";
	
	private Regex nicks;
	private Regex tags;
	private Regex groups;
	private Regex urls;
	private Regex clear_notice;
	
	private Regex twitpic_regex;
	private Regex imgly_regex;
	
	private enum ImageHostings {
		TWITPIC, IMGLY
	}
	
	public StatusDelegate(Status status, AStream stream) {
		try {
			nicks = new Regex("(^|\\s|['\"+&!/\\(-])@([A-Za-z0-9_]+)");
			tags = new Regex("(^|\\s|['\"+&!/\\(-])#([A-Za-z0-9_.-\\p{Latin}\\p{Greek}]+)");
			groups = new Regex("(^|\\s|['\"+&!/\\(-])!([A-Za-z0-9_]+)"); //for identi.ca groups
			urls = new Regex("((https?|ftp)://([A-Za-z0-9+&@#/%?=~_|!:,.;-]*)([A-Za-z0-9+&@#/%=~_|$]))"); // still needs to be improved for urls containing () such as wikipedia's
			
			twitpic_regex = new Regex("(http://twitpic.com/([a-z0-9]+))");
			imgly_regex = new Regex("(http://img.ly/([a-z0-9]+))");
			
			// characters must be cleared to know direction of text
			clear_notice = new Regex("[: \n\t\r♻♺]+|@[^ ]+");
		
			rt_pixbuf = new Gdk.Pixbuf.from_file(Config.RT_PATH);
		} catch (GLib.RegexError e) {
			stderr.printf("%s\n", e.message);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
		
		this.status = status;
		this.stream = stream;
		
		set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
		set_events(Gdk.EventMask.BUTTON_PRESS_MASK);
		button_release_event.connect(on_click);
		button_press_event.connect(on_double_click);
		
		vb_main = new VBox(false, 0);
		
		hb_main = new BgBox(false, 0);
		hb_main.fresh = status.fresh;
		hb_main.favorited = status.favorited;
		
		//update background if fresh status changed
		status.notify["fresh"].connect((s, p) => {
			hb_main.fresh = ((Status) s).fresh;
		});
		
		status.notify["favorited"].connect((s, p) => {
			hb_main.favorited = ((Status) s).favorited;
		});
		
		VBox vb_avatar = new VBox(false, 0);
		vb_right = new VBox(false, 0);
		HBox hb_header = new HBox(false, 0);
		
		//check if retweet
		string av_url = "";
		if(status.retweet == null)
			av_url = status.user.pic;
		else
			av_url = status.retweet.user.pic;
		
		avatar = new Avatar.from_url(av_url, 48);
		vb_avatar.pack_start(avatar, false, false, 4);
		
		//avatar.load_pic();
		
		//header
		nick = new Label(null);
		string user_name = "";
		if(status.retweet == null)
			user_name = status.user.name;
		else
			user_name = status.retweet.user.name;
		
		nick.set_markup("<b>%s</b>".printf(user_name));
		date = new Label(null);
		date.set_markup(date_string.printf(time_to_human_delta(status.created)));
		
		timer = new SmartTimer(60);
		timer.timeout.connect(update_date);
		
		hb_header.pack_start(nick, false, false, 0);
		hb_header.pack_end(date, false, false, 0);
		
		//content
		content = new WrapLabel();
		content.set_markup_plus(format_content(status.content));
		content.link_activated.connect(uri_route);
		main_window.set_focus.connect(unfocused);
		
		vb_right.pack_start(hb_header, false, false, 4);
		vb_right.pack_start(content, false, false, 0);
		
		if(status.retweet != null) {
			HBox re_box = new HBox(false, 0);
			Label re_label = new Label(null);
			re_label.set_markup("<small><b><span foreground='#888'>%s </span>%s</b></small>".printf(_("retweeted by"), status.user.name));
			
			Avatar re_avatar = new Avatar.from_url(status.user.pic, 18);
			
			re_box.pack_start(re_avatar, false, false, 0);
			re_box.pack_start(re_label, false, false, 4);
			vb_right.pack_start(re_box, false, false, 4);
		} else {
			if(status.reply != null) {
				/*HBox re_box = new HBox(false, 0);
				
				Image re_img = new Image.from_file(Config.CONVERSATION_PATH);
				Label re_label = new Label(null);
				re_label.set_markup("<small><b><span foreground='#888'>in reply to </span>%s</b></small>".printf(status.reply.name));
				
				re_box.pack_start(re_img, false, false, 0);
				re_box.pack_start(re_label, false, false, 4);*/
				
				re_label = new ReplyLabel(status.reply.name);
				re_label.set_tooltip(_("Show conversation"));
				
				re_label.clicked.connect(re_label_clicked);
				
				vb_right.pack_start(re_label, false, false, 4);
				
				status.new_reply.connect(add_new_reply);
				status.end_reply.connect(end_reply);
				
			} else {
				HBox spacer = new HBox(false, 0);
				spacer.set_size_request(1, 4);
				vb_right.pack_start(spacer, false, false, 0);
			}
		}
		
		hb_main.pack_start(vb_avatar, false, false, 4);
		hb_main.pack_start(vb_right, true, true, 4);
		
		vb_main.pack_start(hb_main, true, true, 0);
		
		if(status.own) {
			hb_main.reorder_child(vb_right, 0);
			
			hb_header.remove(nick);
			hb_header.remove(date);
			hb_header.pack_start(date, false, false, 0);
			hb_header.pack_end(nick, false, false, 0);
		}
		
		//search for thumbs
		HashMap<string, string>? map = search_for_thumbs(status.content);
		if(map != null) {
			hb_thumbs = new HBox(false, 4);
			vb_right.pack_start(hb_thumbs, false, false, 0);
			
			//add thumbs to the layout
			foreach(string key in map.keys) {
				debug(map[key]);
				//Avatar thumb = new Avatar.from_url(map[key], 75);
				Thumb thumb = new Thumb(map[key], 75, key);
				hb_thumbs.pack_start(thumb, false, false, 0);
				thumb.show_all();
			}
		}
		
		add(vb_main);
		
		//set bg color
		Gdk.Color color = Gdk.Color();
		Gdk.Color.parse("white", out color);
		
		modify_bg(StateType.NORMAL, color);
	}
	
	private void re_label_clicked() {
		re_label.set_sensitive(false);
		re_label.start();
		
		/*
		if(already_expanded) {
			if(con_view.visible) {
				con_view.hide_all();
				re_label.set_tooltip(tooltip_show);
			} else {
				con_view.show_all();
				re_label.set_tooltip(tooltip_hide);
			}
			
			return;
		}*/
		
		stream.account.get_conversation(status);
		
		//already_expanded = true;
	}
	
	private void add_new_reply(Status nstatus) { //new reply received
		debug(nstatus.id);
		
		if(con_view == null) {
			debug("ok");
			con_view = new ConversationView();
			vb_main.pack_start(con_view, false, false, 0);
			con_view.show_all();
		}
		
		con_view.add_delegate(new StatusDelegate(nstatus, stream));
	}
	
	private void end_reply() {
		re_label.stop();
		re_label.set_tooltip("");
	}
	
	private void update_date() {
		date.set_markup(date_string.printf(time_to_human_delta(status.created)));
	}
	
	/** Any click makes it not fresh */
	private bool on_click(Gdk.EventButton event) {
		switch(event.button) {
		case 1: //left click
			if(!status.fresh)
				return true;
			
			status.fresh = false;
			debug("ok");
			return true;
		
		case 3: //context menu
			stream.account.context_menu(stream, status);
			return true;
		
		default:
			return false;
		}
	}
	
	private bool on_double_click(Gdk.EventButton event) {
		if(event.type != Gdk.EventType.2BUTTON_PRESS)
			return false;
		
		debug("double click");
		content.set_selectable(true);
		main_window.set_focus(content);
		
		return true;
	}
	
	private void unfocused(Widget? widget) {
		if(widget == null || widget == content)
			return;
		
		content.set_selectable(false);
	}
	
	private void uri_route(string prot, string uri) {
		switch(prot) {
		case "search":
			stream.account.go_hashtag(uri);
			break;
		
		case "group":
			stream.account.go_group(uri);
			break;
		
		case "userinfo":
			debug("not implemented");
			break;
		
		default:
			GLib.Pid pid;
			try {
				GLib.Process.spawn_async(".", {"/usr/bin/xdg-open", prot + "://" + uri}, null,
					GLib.SpawnFlags.STDOUT_TO_DEV_NULL, null, out pid);
			} catch (GLib.SpawnError e) {
				stderr.printf("%s\n", e.message);
			}
			break;
		}
	}
	
	/** Here we draw some things like retweet indicator and others */
	public override bool expose_event(Gdk.EventExpose event) {
		if(status == null || status.retweet == null)
			return base.expose_event(event);
		
		Context ctx = Gdk.cairo_create(this.window);
		
		base.expose_event(event);
		
		if(rt_pixbuf != null) {
			Gdk.Rectangle big_rect = {0, 0 , 48, 48};
			Gdk.cairo_rectangle(ctx, big_rect);
			Gdk.cairo_set_source_pixbuf(ctx, rt_pixbuf, big_rect.x,
				big_rect.y);
			
			ctx.fill();
		}
		
		return false;
	}
	
	/** Convert status time to human readable string */
	private string time_to_human_delta(string created, bool is_search = false) {
		string currentLocale = GLib.Intl.setlocale(GLib.LocaleCategory.TIME, null);
		GLib.Intl.setlocale(GLib.LocaleCategory.TIME, "C");
		
		int delta = TimeParser.time_to_diff(created, is_search);
		
		if(delta < 30)
			return _("a few seconds ago");
		if(delta < 120) {
			//timer.set_interval(120);
			return _("1 minute ago");
		}
		if(delta < 3600) {
			timer.set_interval(300);
			return _("%i minutes ago").printf(delta / 60);
		}
		if(delta < 7200) {
			timer.set_interval(3600);
			return _("about 1 hour ago");
		}
		if(delta < 86400) {
			timer.set_interval(3600);
			return _("about %i hours ago").printf(delta / 3600);
		}
		
		timer.set_interval(0);
		
		GLib.Intl.setlocale(GLib.LocaleCategory.TIME, currentLocale);
		
		return TimeUtils.str_to_time(created).format("%k:%M %b %d %Y");
	}
	
	private string format_content(owned string data) {
		string tmp = data;
		
		int pos = 0;
		while(true) {
			//url cutting
			MatchInfo match_info;
			bool bingo = false;
			try {
				bingo = urls.match_all_full(tmp, -1, pos, GLib.RegexMatchFlags.NEWLINE_ANY, out match_info);
			} catch (GLib.RegexError e) {
				stderr.printf("%s\n", e.message);
			}
			if(bingo) {
				foreach(string s in match_info.fetch_all()) {
					if(s.length > 30) {
						data = data.replace(s, """<a href="%s" title="%s">%s...</a>""".printf(s, s, s.substring(0, 30)));
					} else {
						data = data.replace(s, """<a href="%s">%s</a>""".printf(s, s));
					}
					
					match_info.fetch_pos(0, null, out pos);
					break;
				}
			} else break;
		}
		try {
			data = nicks.replace(data, -1, 0, "\\1<b><a href='userinfo://\\2'><span foreground='=fg-color='>@\\2</span></a></b>");
			data = tags.replace(data, -1, 0, "\\1<b><a href='search://\\2'>#\\2</a></b>");
			data = groups.replace(data, -1, 0, "\\1<b>!<a href='group://\\2'>\\2</a></b>");
			data = data.replace("=fg-color=", visual_style.fg_color);
		} catch (GLib.RegexError e) {
			stderr.printf("%s\n", e.message);
		}
		return data;
	}
	
	/** Return hashmap with urls and urls of thumbs or null */
	private HashMap<string, string>? search_for_thumbs(string text) {
		HashMap<string, string> map = new HashMap<string, string>();
		
		extract_thumbs(text, map, twitpic_regex, ImageHostings.TWITPIC);
		extract_thumbs(text, map, imgly_regex, ImageHostings.IMGLY);
		
		if(map.size == 0)
			return null;
		
		return map;
	}
	
	private void extract_thumbs(string text, HashMap<string, string> map,
		Regex regex, ImageHostings hosting_type) {
		
		int pos = 0;
		while(true) {
			MatchInfo match_info;
			bool bingo = false;
			try {
				bingo = regex.match_all_full(text, -1, pos, GLib.RegexMatchFlags.NEWLINE_ANY, out match_info);
			} catch (GLib.RegexError e) {
				stderr.printf("%s\n", e.message);
			}
			if(bingo) {
				foreach(string s in match_info.fetch_all()) {
					switch(hosting_type) {
					case ImageHostings.TWITPIC:
						map[s] = "http://twitpic.com/show/mini/" + s.split("twitpic.com/")[1];
						break;
					case ImageHostings.IMGLY:
						map[s] = "http://img.ly/show/mini/" + s.split("img.ly/")[1];
						break;
					}
					
					match_info.fetch_pos(0, null, out pos);
					break;
				}
			} else break;
		}
	}
}
