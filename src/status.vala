using Gee;

public class Status : GLib.Object {
	
	public bool fresh {get; set; default = false;}
	
	public string id {get; set; default = "";}
	public string content {get; set; default = "";}
	public bool own {get; set; default = false;}
	public User user {get; set; default = new User();}
	public Status? retweet {get; set; default = null;}
	public bool favorited {get; set; default = false;}
	public string created {get; set; default = "";}
	public Reply? reply {get; set; default = null;}
	
	public ArrayList<Status>? conversation {get; set; default = null;}
	
	public signal void new_reply(Status status);
	public signal void end_reply();
}

public class User : GLib.Object {
	
	public string name {get; set; default = "";}
	public string name_long {get; set; default = "";}
	public string pic {get; set; default = "";}
}

public class Reply: GLib.Object {
	public string name {get; set; default = "";}
	public string status_id {get; set; default = "";}
}
