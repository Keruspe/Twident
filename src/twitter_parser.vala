using Rest;
using Gee;
using Xml;
using TimeUtils;

namespace Twitter {

public class Parser : GLib.Object {

	public static ArrayList<Status> get_timeline(string data, string own_name) {
		ArrayList<Status> lst = new ArrayList<Status>();
		
		XmlParser parser = new XmlParser();
		XmlNode root = parser.parse_from_data(data, (int64) data.size());
		
		if(root.children == null && root.children.size() < 1)
			return lst;
		
		XmlNode? status_node = (XmlNode) root.children.get_values().nth_data(0);
		
		while(status_node != null) {
			Status status = get_status(status_node, own_name);
			if(status != null)
				lst.add(status);
			
			status_node = status_node.next;
		}
		
		return lst;
	}
	
	public static Status? get_status_from_string(string data, string own_name) {
		XmlParser parser = new XmlParser();
		XmlNode root = parser.parse_from_data(data, (int64) data.size());
		
		XmlNode? status_node = (XmlNode) root;//.get_values().nth_data(0);
		
		return get_status(status_node, own_name);
	}
	
	public static Status? get_status(XmlNode node, string own_name) {
		Status status = new Status();
		
		foreach(var val in node.children.get_values()) {
			XmlNode snode = (XmlNode) val;
			
			switch(snode.name) {
			case "id":
				status.id = snode.content;
				break;
			
			case "text":
				status.content = snode.content;
				break;
			
			case "created_at":
				status.created = snode.content;
				break;
			
			case "in_reply_to_screen_name":
				if(snode.content != null) {
					if(status.reply == null)
						status.reply = new Reply();
					
					status.reply.name = snode.content;
				}
				break;
			
			case "in_reply_to_status_id":
				if(snode.content != null) {
					if(status.reply == null)
						status.reply = new Reply();
					
					debug(snode.content);
					status.reply.status_id = snode.content;
				}
				break;
			
			case "user":
				if(get_user(snode, status.user, own_name))
					status.own = true;
				break;
			
			case "retweeted_status":
				status.retweet = get_status(snode, own_name);
				break;
			case "favorited":
				if(snode.content == "true")
					status.favorited = true;
				break;
			}
		}
		
		if(status.user.name == "")
			return null;
		
		return status;
	}
	
	public static User? get_single_user(string data) {
		XmlParser parser = new XmlParser();
		XmlNode root = parser.parse_from_data(data, (int64) data.size());
		
		User user = new User();
		get_user(root, user, "");
		
		return user;
	}
	
	/** Insert user object into status. Returns true, if status is owned */
	public static bool get_user(XmlNode node, User user, string own_name) {
		bool own = false;
		
		foreach(var val in node.children.get_values()) {
			XmlNode unode = (XmlNode) val;
			
			switch(unode.name) {
			case "screen_name":
				user.name = unode.content;
				if(user.name == own_name)
					own = true;
				break;
			
			case "name":
				user.name_long = unode.content;
				break;
			
			case "profile_image_url":
				user.pic = unode.content;
				break;
			}
		}
		
		return own;
	}
	
	public static ArrayList<Status> get_search(string data, string own_name) {
		ArrayList<Status> lst = new ArrayList<Status>();
		Xml.Doc* xml_doc = Xml.Parser.parse_memory(data, (int) data.size());
		Xml.Node* root_node = xml_doc->get_root_element();
		
		Xml.Node* iter;
		
		for(iter = root_node->children; iter != null; iter = iter->next) {
			if(iter->type != ElementType.ELEMENT_NODE)
				continue;
			
			debug(iter->name);
			if(iter->name == "entry")
				lst.add(get_search_status(iter, own_name));
		}
		
		delete iter;
		delete root_node;
		
		return lst;
	}
	
	public static Status get_search_status(Xml.Node* node, string own_name) {
		Status status = new Status();
		
		Regex nick_re = new Regex("(.*) \\((.*)\\)");
		
		Xml.Node* iter;
		for(iter = node->children->next; iter != null; iter = iter->next) {
			if(iter->type != ElementType.ELEMENT_NODE)
				continue;
			
			//debug("%s: %s", iter->name, iter->get_content());
			
			switch(iter->name) {
			case "id":
				status.id = iter->get_content().split(":")[2];
				break;
			
			case "title":
				status.content = iter->get_content();
				break;
			
			case "updated":
				status.created = iter->get_content();
				break;
			
			case "link":
				string? rel = iter->get_no_ns_prop("rel");
				if(rel == "image" || rel == "related") {
					status.user.pic = iter->get_no_ns_prop("href");
				}
				break;
			
			case "author":
				Xml.Node* iter_a;
				
				for(iter_a = iter->children->next; iter_a != null; iter_a = iter_a->next) {
					if(iter_a->name == "name") {
						string[] split_result = nick_re.split(iter_a->get_content());
						if(split_result.length == 1) {
							status.user.name = split_result[0];
							status.user.name_long = split_result[0];
						} else {
							status.user.name = split_result[1];
							status.user.name_long = split_result[2];
						}
						break;
					}
				}
				
				break;
			}
		}
		
		delete iter;
		return status;
	}
}

}
