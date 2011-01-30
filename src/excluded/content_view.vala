using Gtk;
using WebKit;
using Gee;

public class ContentView : GLib.Object {
	
	private WebView? view;
	private ScrolledWindow scroll;
	protected VScrollbar slider;
	public Frame frame;
	private Accounts accounts;
	private VisualStyle visual_style;
	private Template tpl;
	
	private HashMap<string, string> content_map;
	private HashMap<string, string> scroll_map;
	
	private string current_stream = "";
	
	private bool not_more = false;
	
	public ContentView(Accounts accounts, VisualStyle visual_style) {
		view = new WebView();
		view.set_size_request(250, 350);
		view.navigation_policy_decision_requested.connect(event_route);
		view.settings.enable_default_context_menu = false;
		
		scroll = new ScrolledWindow(null, null);
		scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		scroll.add(view);
		
		slider = (VScrollbar)scroll.get_vscrollbar();
		
		frame = new Frame(null);
		frame.add(scroll);
		
		content_map = new HashMap<string, string>(str_hash, str_equal);
		scroll_map = new HashMap<string, string>(str_hash, str_equal);
		
		view.load_finished.connect((f) => {
			update_style();
			
		});
		
		//when scroll to the bottom
		slider.value_changed.connect(slider_move);
		
		this.accounts = accounts;
		this.visual_style = visual_style;
		this.visual_style.changed.connect(update_style);
		
		tpl = new Template(this.visual_style);
		
		view.load_string(tpl.render_body(), "text/html", "utf8", "file:///");
		
		this.accounts.stream_was_updated.connect(generate_list);
		
		this.accounts.insert_reply.connect(insert_reply);
	}
	
	private void insert_reply(string stream_hash, string status_id, Status status) {
		if(stream_hash != current_stream) {
			debug("not this stream");
			return;
		}
		
		AStream? stream = accounts.stream_from_hash(stream_hash);
		if(stream == null) {
			debug("can't find this stream");
			return;
		}
		
		string result = tpl.render_small_status(status, stream);
		result = result.replace("'", "\\'");
		debug(result);
		
		string script = """insert_reply('%s', '%s');""".printf(status_id, result);
		script = script.replace("\n", " ");
		view.execute_script(script);
	}
	
	private void slider_move() {
		double max = slider.adjustment.upper;
		double current = slider.get_value();
		double scroll_size = slider.adjustment.page_size;
		
		if(!not_more && current != 0 && current + scroll_size == max) {
			debug("need more");
			AStream? stream = accounts.stream_from_hash(current_stream);
			
			if(stream == null)
				return;
			
			stream.menu_more();
		}
	}
	
	private void generate_list(string hash, AStream stream) {
		debug(hash);
		
		if(stream.statuses.size == 0 && stream.statuses_fresh.size == 0)
			return;
		
		string data = tpl.stream_to_list(stream, hash);
		data = data.replace("\n", " ");
		data = data.replace("'", "\\'");
		content_map.set(hash, data);
		
		if(hash == current_stream)
			set_current_list(hash);
	}
	
	public void set_current_list(string? hash) {
		if(hash == null)
			return;
		
		not_more = true;
		
		if(current_stream != "")
			scroll_map[current_stream] = slider.get_value().to_string();
		
		current_stream = hash;
		
		if(content_map.has_key(hash)) {
			//view.load_string(content_map.get(hash), "text/html", "utf8", "file:///");
			load_content(content_map.get(hash));
		} else {
			load_content("empty");
		}
		
		if(scroll_map.has_key(current_stream)) {
			slider.set_value(scroll_map[current_stream].to_double());
		}
		
		not_more = false;
	}
	
	protected void load_content(owned string data) {
		string script = """set_content('%s');""".printf(data);
		view.execute_script(script);
	}
	
	private void update_style() {
		view.settings.set_property("default-font-size", visual_style.font_size);
		view.settings.set_property("default-font-family", visual_style.font_family);
		
		string header = tpl.render_header();
		
		/*
		accounts.update_all_streams();
		
		set_current_list(current_stream);
		*/
		
		string script = """change_style("%s");""".printf(header);
		script = script.replace("\n", " ");
		view.execute_script(script);
		
		debug("style changed");
	}
	
	private bool event_route(WebFrame p0, NetworkRequest request,
		WebNavigationAction action, WebPolicyDecision decision) {
		if(request.uri == "")
			return false;
		
		string prot = request.uri.split("://")[0];
		string path = request.uri.split("://")[1];
		debug(prot);
		debug(path);
		
		if(prot == "file")
			return false;
		
		if(prot == "http" || prot == "https" || prot == "ftp") {
			GLib.Pid pid;
			GLib.Process.spawn_async(".", {"/usr/bin/xdg-open", request.uri}, null,
				GLib.SpawnFlags.STDOUT_TO_DEV_NULL, null, out pid);
			return true;
		}
		
		accounts.new_content_action(prot, path);
		
		return true;
	}
}
