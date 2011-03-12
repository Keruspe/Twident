using Gee; 
using Xml;
using TwidentEnums;

public class Settings : Object {
	
	public int vpaned_position {get; set; default = 400;}
	public int hpaned_position {get; set; default = 150;}
	
	public string current_item {get; set; default = "";}
	
	public ArrayList<string> selected_for_posting {get; set; default = new ArrayList<string>();}
	
	private string settings_path;
	
	public Settings() {
		string app_dir = Environment.get_user_config_dir() + "/%s".printf(Config.APPNAME);
		
		var dir = File.new_for_path(app_dir);
		
		if(!dir.query_exists(null)) {
			try {
				dir.make_directory(null);
			} catch(GLib.Error e) {
				debug(e.message); //TODO
			}
		}
		
		dir = null;
		
		settings_path = app_dir + "/settings.xml";
		File opt_file = File.new_for_path(settings_path);
		
		if(opt_file.query_exists(null)) {
			FileInputStream fstream;
			try {
				fstream = opt_file.read(null);
			} catch(GLib.Error e) {
				debug(e.message); //TODO
				return;
			}
			DataInputStream stream = new DataInputStream(fstream);
			
			string data;
			try {
				data = stream.read_until("", null, null);
			} catch(GLib.Error e) {
				debug(e.message); //TODO
				return;
			}
			from_xml(data);
		}
	}
	
	public void sync() {
		File file = File.new_for_path(settings_path);
		
		FileOutputStream stream;
		try {
			stream = file.replace(null, false, FileCreateFlags.NONE, null);
		} catch(GLib.Error e) {
			debug(e.message); //TODO
			return;
		}
		
		DataOutputStream data_stream = new DataOutputStream(stream);
		
		try {
			data_stream.put_string(to_xml(), null);
		} catch(GLib.Error e) {
			debug(e.message); //TODO
		}
	}
	
	/** Converting values to string */
	public static string value_to_string(Value v, Type t) {
		switch(t.name()) {
		case "gint":
			return v.get_int().to_string();
		
		case "gdouble":
			return v.get_double().to_string();
		
		case "gboolean":
			return v.get_boolean().to_string();
		
		case "gchararray":
			return v.get_string();
		
		case "TwidentEnumsStreamEnum":
			return v.get_enum().to_string();
		
		case "GeeArrayList": //strings only!
			ArrayList<string> obj = (ArrayList<string>) v.get_object();
			string result = "";
			
			foreach(string s in obj) {
				if(s != "")
					result += s + "\t==+-=";
			}
			
			return result;
		
		default:
			return "";
		}
	}
	
	/** Restoring values from string */
	public static Value? value_from_string(string data, Type t) {
		Value? v = Value(t);
		
		switch(t.name()) {
		case "gint":
			v.set_int(int.parse(data));
			break;
		
		case "gdouble":
			v.set_double(double.parse(data));
			break;
		
		case "gboolean":
			v.set_boolean(bool.parse(data));
			break;
		
		case "gchararray":
			v.set_string(data);
			break;
		
		case "TwidentEnumsStreamEnum":
			v.set_enum(int.parse(data));
			break;
		
		case "GeeArrayList":
			ArrayList<string> string_list = new ArrayList<string>();
			string[] strings = data.split("\t==+-=");
			foreach(string s in strings) {
				if(s != "")
					string_list.add(s);
			}
			
			v.set_object(string_list);
			break;
		
		default:
			v = null;
			break;
		}
		
		return v;
	}
	
	/** Save settings properties to xml */
	public string to_xml() {
		string props = "";
		
		var obj = (ObjectClass) this.get_type().class_ref();
		
		foreach(var p in obj.list_properties()) {
			Value v = Value(p.value_type);
			this.get_property(p.get_name(), ref v);
			
			string s_val = value_to_string(v, p.value_type);
			if(s_val != "")
				props += "\t<%s>%s</%s>\n".printf(p.get_name(), s_val, p.get_name());
		}
		
		string result = "\n<settings>\n%s</settings>".printf(props);
		
		return result;
	}
	
	/** Restore settings from xml */
	public void from_xml(string data) {
		Doc* xml_doc = Parser.parse_memory(data, (int) data.length);
		Xml.Node* root_node = xml_doc->get_root_element();
		
		if(root_node == null)
			return;
		
		HashMap<string, string> opt_map = new HashMap<string, string>();
		
		for(Xml.Node* iter = root_node->children; iter != null; iter = iter->next) {
			if(iter->type != ElementType.ELEMENT_NODE)
				continue;
			
			debug(iter->name);
			opt_map.set(iter->name, iter->get_content());
		}
		
		var obj = (ObjectClass) this.get_type().class_ref();
		
		foreach(var p in obj.list_properties()) {
			string? pval = opt_map.get(p.get_name());
			
			if(pval == null)
				continue;
			
			Value? val = Settings.value_from_string(pval, p.value_type);
			
			if(val == null) {
				debug("this value type is not supported");
				continue;
			}
			
			this.set_property(p.get_name(), val);
		}
	}
}
