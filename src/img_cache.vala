using Soup;
using Gee;

public class ImgCache : Object {
	
	private Regex url_re;
	private string cache_path;
	private HashMap<string, Gdk.Pixbuf> map;
	
	construct {
		try {
			url_re = new Regex("(http://)([a-zA-Z0-9-\\.]+)/(.*)");
		} catch(GLib.RegexError e) {
			debug(e.message);
		}
		
		cache_path = Environment.get_user_cache_dir() + "/%s".printf("twident/");
		
		var cache_dir = File.new_for_path(cache_path);
		
		if(!cache_dir.query_exists(null)) {
			try {
				cache_dir.make_directory(null);
			} catch(GLib.Error e) {
				debug(e.message); //TODO
			}
		}
		
		map = new HashMap<string, Gdk.Pixbuf>();
	}
	
	private void load_pix(string path) {
		if(!map.has_key(path)) {
			map[path] = new Gdk.Pixbuf.from_file(path);
		}
		
		/*
		if(map[path].width > 48 || map[path].height > 48) {
			map[path] = map[path].scale_simple(48, 48, Gdk.InterpType.BILINEAR);
		}*/
	}
	
	public Gdk.Pixbuf? from_cache(string path) {
		load_pix(path);
		
		return map[path];
	}
	
	public bool exist(string url) {
		string new_path = cache_path + url_to_name(url);	
		File f = File.new_for_path(new_path);
		
		if(!f.query_exists(null))
			return false;
		else
			return true;
		
	}
	
	public string? download(string url) {
		if(exist(url))
			return cache_path + url_to_name(url);
		
		Session session = new SessionSync();
		Message msg;
		
		try {
			msg = new Message("GET", encode_url(url));
		} catch(GLib.RegexError e) {
			debug(e.message);
			return null;
		}
		
		int status_code = 0;
		
		status_code = (int) session.send_message(msg);
		
		if(status_code != 200) {
			debug("status code is %d", status_code);
			return null;
		}
		
		//string data = (string) msg.response_body.flatten().data;
		string new_path = cache_path + url_to_name(url);
		
		if(!Soppa.save_soup_data(msg.response_body, new_path))
			return null;
		
		load_pix(new_path);
		
		return new_path;
	}
	
	private string url_to_name(string url) {
		string save_name = url.replace("/", "");
		return save_name;
	}
	
	private string encode_url(string url) throws GLib.RegexError {
		string old_url_path = url_re.replace(url, -1, 0, "\\3");
		string new_url_path = Soup.form_encode("", old_url_path).split("=")[1];
		new_url_path = url.replace(old_url_path, new_url_path);
	
		new_url_path = new_url_path.replace("%2F", "/");
				
		return new_url_path;
	}
}
