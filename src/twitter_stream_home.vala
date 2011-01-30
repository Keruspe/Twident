using Gee;
using TwidentEnums;
using Rest;

namespace Twitter {

public class StreamHome : Twitter.StreamAbstract {

	public override StreamEnum stream_type {get { return StreamEnum.HOME; } }

	public override MenuItems[] popup_items {
		owned get {
			return {
				MenuItems.REFRESH,
				MenuItems.SETTINGS,
				MenuItems.MORE,
				MenuItems.REMOVE
			};
		}
	}
	
	private override string func {get; set; default = "statuses/home_timeline.xml";}
	
	public int64 s_last_id {get; set; default = 0;}
	
	public override string id {get; set; default = "home";}
	
	protected delegate ArrayList<Status> ParsingDelegate(string data, string own_name);
	
	protected ParsingDelegate? parsing_delegate = null;
	
	construct {
		debug("twitter home stream was created");
		
		parsing_delegate = Parser.get_timeline;
	}
	
	protected override void set_call_params(bool more = false) {
		if(s_last_id > 0) {
			call.remove_param("max_id");
			call.remove_param("since_id");
				
			if(!more) {
				call.add_param("since_id", s_last_id.to_string());
			} else {
				call.add_param("max_id", model.get(model.size - 1).id);
			}
		}
	}
	
	protected override void parse_stream(string data) {
		ArrayList<Status> result_lst = parsing_delegate(data, own_name);//Parser.get_timeline(data, own_name);
		
		if(result_lst.size == 0) {
			fresh_items = 0;
			fresh_to_normal();
			return;
		}
		
		if(s_last_id == 0) {
			model.add_all(result_lst);
			s_last_id = model.get(0).id.to_int64();
			
			return;
		}
		
		fresh_items = result_lst.size;
		
		fresh_to_normal();
		
		foreach(Status status in result_lst) {
			status.fresh = true;
		}
		
		//getting fresh statuses
		model.add_all(result_lst);
		
		s_last_id = model.get(0).id.to_int64();
		
		/*
		int own_statuses = 0;
		foreach(Status status in statuses_fresh) {
			if(status.own)
				own_statuses += 1;
		}
		
		fresh_items = statuses_fresh.size - own_statuses;
		*/
		debug("What we got: %d", result_lst.size);
	}
	
	protected override void parse_more_stream(string data) {
		ArrayList<Status> result_lst = parsing_delegate(data, own_name);
		
		if(result_lst.size > 1) {
			//model.add_all(result_lst.slice(2, result_lst.size - 1));
			int i = 0;
			foreach(Status status in result_lst) {
				if(i != 0)
					model.add(status);
				
				i++;
			}
		}
	}
	
	/* Moving fresh statuses to the normal statuses */
	protected void fresh_to_normal() {
		foreach(Status status in model) {
			status.fresh = false;
		}
	}
	
	public override void menu_more() {
		debug("more");
		sync(true);
	}
}

}
