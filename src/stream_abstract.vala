using Gee;
using TwidentEnums;

public abstract class AStream : Object {
	
	public AAccount account;
	
	public signal void updated();
	
	public ArrayList<Status> statuses {get; set; default = new ArrayList<Status>();}
	
	public ArrayList<Status> statuses_fresh {get; set; default = new ArrayList<Status>();}
	
	public FeedModel model {get; set; default = new FeedModel();}
	
	public abstract StreamEnum stream_type {get;}
	
	public StreamStatus status {get; set; default = StreamStatus.READY;}
	
	public abstract string id {get; set;}
	
	public string s_hash {get; set; default = "";}
	
	public abstract MenuItems[] popup_items {owned get;}
	
	/** Update interval in secs */
	public virtual int s_update_interval {get; set; default = 5000;}
	
	public int fresh_items {get; set; default = 0;}
	
	construct {
		model.stream = this;
	}
	
	public virtual void menu_refresh() {
	}
	
	public virtual void menu_settings() {
	}
	
	public virtual void menu_more() {
	}
}
