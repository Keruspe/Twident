using Gee;
using Xml;
using TwidentEnums;

public class Accounts : ArrayList<AAccount> {
	
	public signal void insert_new_account(AAccount account);
	public signal void insert_new_stream_after(string after_path, AStream stream);
	public signal void account_was_removed(AAccount account);
	public signal void fresh_items_changed(int items, string path);
	public signal void account_was_changed(string path, AAccount account);
	public signal void stream_was_changed(string path, AStream stream);
	public signal void stream_was_updated(string hash, AStream stream);
	public signal void status_sent(AAccount account, bool ok, string error_msg = "");
	public signal void message_indicate(string msg);
	public signal void stop_indicate();
	public signal void do_reply(AAccount account, Status status);
	public signal void insert_reply(string stream_hash, string status_id, Status result);
        public signal void cursor_changed(AStream? new_stream, AStream? old_stream);
        public signal void current_changed(AAccount? new_account, AAccount? old_account);
		
		private AAccount? _current = null;
		public AAccount? current {
		get {
		return _current;
		}
		set {
		if(value == _current)
		return;		
		if(contains(value)) {
		current_changed(value, _current); //emit signal
		
		if(value != null) {
		AStream? old_stream = _current.streams.get_current();
		AStream? new_stream = null;
		
		new_stream = value.streams.get_current();
		value.streams.cursor_changed(new_stream, old_stream);
		}
		
		_current = value;
		settings.current_account = index_of(_current);
		}
		}
		}
	
	private string accounts_path;
	
	public Accounts() {
		base();
		
		init();
		if(settings != null && this.size -1 >= settings.current_account) {
		current = get(settings.current_account);
		}
	}
		/*
		public void set_current(AAccount? account) {
		if(account == current)
		return;
		
		if(contains(account)) {
		current_changed(account, current); //emit signal
		current = account;
		} else {
		debug("no account");
		}
		}*/
	
	private void init() {
		string app_dir = Environment.get_user_config_dir() + "/%s".printf(Config.APPNAME);
		
		var dir = File.new_for_path(app_dir);
		
		if(!dir.query_exists(null)) {
			try {
				dir.make_directory(null);
			} catch(GLib.Error e) {
			}
		}
		
		dir = null;
		
		accounts_path = app_dir + "/accounts.xml";
		File acc_file = File.new_for_path(accounts_path);
		
		if(acc_file.query_exists(null)) {
			FileInputStream fstream;
			try {
				fstream = acc_file.read(null);
			} catch(GLib.Error e) {
				return;
			}
			DataInputStream stream = new DataInputStream(fstream);
			
			string data;
			try {
				data = stream.read_until("", null, null);
			} catch(GLib.Error e) {
				return;
			}
			from_xml(data);
		}
	}
	
	public void sync() {
		File file = File.new_for_path(accounts_path);
		
		FileOutputStream stream;
		try {
			stream = file.replace(null, false, FileCreateFlags.NONE, null);
		} catch(GLib.Error e) {
			return;
		}
		
		DataOutputStream data_stream = new DataOutputStream(stream);
		
		try {
			data_stream.put_string(to_xml(), null);
		} catch(GLib.Error e) {
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
		
		default:
			v = null;
			break;
		}
		
		return v;
	}
	
	/** Save all accounts and it's streams properties to xml */
	public string to_xml() {
		string result = "\n<accounts>\n%s</accounts>";
		string istr = "";
		
		foreach(AAccount account in this) {
			var obj = (ObjectClass) account.get_type().class_ref();
			
			string account_str = "\t<account type=\"%s\">\n%s\t</account>\n";
			string account_props = "";
			
			foreach(var p in obj.list_properties()) {
				
				if(p.get_name().substring(0, 2) != "s-") //we need only s-* properties
					continue;
				
				Value v = Value(p.value_type);
				account.get_property(p.get_name(), ref v);
			
				string s_val = value_to_string(v, p.value_type);
			
				if(s_val != "")
					account_props += "\t\t<%s>%s</%s>\n".printf(p.get_name(), s_val, p.get_name());
			}
			
			string streams_result = "\t\t<streams>\n%s\t\t</streams>\n";
			string streams_str = "";
			
			foreach(AStream stream in account.streams) { //saving streams
				var obj_stream = (ObjectClass) stream.get_type().class_ref();
				string stream_str = "\t\t\t<stream type=\"%d\">\n%s\t\t\t</stream>\n";
				string stream_props = "";
				
				foreach(var p in obj_stream.list_properties()) {
					if(p.get_name().substring(0, 2) != "s-") //we need only s-* properties
						continue;
					
					Value v = Value(p.value_type);
					stream.get_property(p.get_name(), ref v);
					
					string s_val = value_to_string(v, p.value_type);
					
					if(s_val != "")
						stream_props += "\t\t\t\t<%s>%s</%s>\n".printf(p.get_name(), s_val, p.get_name());
				}
				
				streams_str += stream_str.printf(stream.stream_type, stream_props);
			}
			
			account_props += streams_result.printf(streams_str);
			
			istr += account_str.printf(account.get_type().name(), account_props);
		}
		
		return result.printf(istr);
	}
	
	/** Restore accounts and streams from xml */
	public void from_xml(string data) {
		Doc* xml_doc = Parser.parse_memory(data, (int) data.length);
		Xml.Node* root_node = xml_doc->get_root_element();
		
		if(root_node == null)
			return;
		
		for(Xml.Node* iter = root_node->children; iter != null; iter = iter->next) {
			if(iter->type != ElementType.ELEMENT_NODE || iter->name != "account")
				continue;
			
			string? account_type = iter->get_prop("type");
			if(account_type == null)
				continue;
			
			AAccount account = (AAccount) Object.new(Type.from_name(account_type));
			prepare_account(account);
			
			HashMap<string, string> account_map = new HashMap<string, string>();
			
			/** Getting properties into hashmap and adding streams to account */
			for(Xml.Node* iter_acc = iter->children; iter_acc != null; iter_acc = iter_acc->next) {
				if(iter_acc->type != ElementType.ELEMENT_NODE)
					continue;
				
				switch(iter_acc->name) {
				case "streams": //streams list
					for(Xml.Node* iter_streams = iter_acc->children; iter_streams != null; iter_streams = iter_streams->next) {
						if(iter_streams->type != ElementType.ELEMENT_NODE || iter_streams->name != "stream")
							continue;
						string? stream_type = iter_streams->get_prop("type");
						if(stream_type == null)
							continue;
						
						HashMap<string, string> stream_map = new HashMap<string, string>();
						
						for(Xml.Node* iter_stream = iter_streams->children; iter_stream != null; iter_stream = iter_stream->next) {
							if(iter_stream->type != ElementType.ELEMENT_NODE)
								continue;
							
							stream_map.set(iter_stream->name, iter_stream->get_content());
						}
						
						account.add_stream((StreamEnum) int.parse(stream_type),
							false, stream_map);
					}
					break;
				
				default: //all other properties
					account_map.set(iter_acc->name, iter_acc->get_content());
					break;
				}
			}
			
			/** Setting properties to account */
			var obj = (ObjectClass) Type.from_name(account_type).class_ref();
			foreach(var p in obj.list_properties()) {
				string? pval = account_map.get(p.get_name());
				
				if(pval == null)
					continue;
				
				Value? val = value_from_string(pval, p.value_type);
				
				if(val == null) {
					continue;
				}
				
				account.set_property(p.get_name(), val);
			}
			
			account.post_install();
			add(account);
		}
	}
	
	/** Add new account */
	public void add_account(Type t, Gtk.Window w) {
		AAccount account = (AAccount) GLib.Object.new(t);
		
		if(!account.create(w))
			return;
		
		prepare_account(account);
		account.post_install();
		
		add(account);
		insert_new_account(account); //emit signal
		current = account;
	}
	
	private void prepare_account(AAccount account) {
		account.stream_was_added.connect(new_stream);
		account.stream_was_removed.connect(remove_stream);
		account.account_was_changed.connect(account_update);
		account.stream_was_changed.connect(stream_change);
		account.stream_was_updated.connect(stream_update);
		account.status_sent.connect((ac, ok, msg) => {
			status_sent(ac, ok, msg);
		});
		account.message_indicate.connect((msg) => {
			message_indicate(msg);
		});
		account.stop_indicate.connect(() => {
			stop_indicate();
		});
		
		account.do_reply.connect((acc, status) => {
			do_reply(acc, status);
		});
		
		account.insert_reply.connect((stream_hash, status_id, result) => {
			insert_reply(stream_hash, status_id, result);
		});

                account.cursor_changed.connect((new_stream, old_stream) => {
                    cursor_changed(new_stream, old_stream);
                });
	}

	/** New stream was added, we need to report about this to the tree widget */
	private void new_stream(AAccount account, AStream stream) {
		int account_index = index_of(account);
		insert_new_stream_after(account_index.to_string(), stream);
	}
	
	/** Stream was removed from some account */
	private void remove_stream(AAccount account, AStream stream) {
		//int account_index = index_of(account);
		//element_was_removed("%d:%d".printf(account_index, stream_index), account, stream);
	}
	
	/** New data in account */
	private void account_update(AAccount account) {
		int account_index = index_of(account);
		account_was_changed(account_index.to_string(), account);
	}
	
	/** New data in stream */
	private void stream_change(AAccount account, AStream stream, int stream_index) {
		int account_index = index_of(account);
		stream_was_changed("%d:%d".printf(account_index, stream_index), stream);
	}
	
	/** Generate list from stream */
	private void stream_update(string hash, AStream stream) {
		stream_was_updated(hash, stream);
	}
	
	/** Send 'updated' signal from all streams */
	public void update_all_streams() {
		foreach(AAccount account in this) {
			foreach(AStream stream in account.streams) {
				stream.updated();
			}
		}
	}
	
	/** Somesing pressed in content view */
	public void new_content_action(string action_type, string path) {
		string[] params = path.split("##");
		
		if(params.length < 3)
			return;
		
		string account_hash = params[0];
		string stream_hash = params[1];
		string val = params[2];
		
		
		AAccount? account = null;
		foreach(AAccount acc in this) {
			if(acc.get_hash() == account_hash) {
				account = acc;
				break;
			}
		}
		
		if(account == null) {
			return;
		}
		
		account.new_content_action(action_type, stream_hash, val);
	}
	
	/** Return stream from hash */
	public AStream? stream_from_hash(string hash) {
		foreach(AAccount account in this) {
			foreach(AStream fstream in account.streams) {
				if(account.get_stream_hash(fstream) == hash)
					return fstream;
			}
		}
		
		return null;
	}
	
	/** Action for accounts */
	public void actions_tracker(AAccount account, MenuItems item) {
		
		switch(item) {
		case MenuItems.REMOVE:
			Gtk.MessageDialog dlg = new Gtk.MessageDialog(main_window, Gtk.DialogFlags.MODAL,
				Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
				"%s", _("Do you realy want to remove this account?"));
			
			int result = dlg.run();
			dlg.close();
			
			if(result == Gtk.ResponseType.YES) {
				//int account_index = index_of(account);
				account_was_removed(account);
				this.remove(account);
			}
			break;
		}
	}
	
	public AAccount? get_by_hash(string hash) {
		foreach(AAccount account in this) {
			if(account.get_hash() == hash)
				return account;
		}
		
		return null;
	}
}
