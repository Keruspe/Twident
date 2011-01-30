using Gee;
using TwidentEnums;

namespace Twitter {

public class StreamSearch : Twitter.StreamHome, ISearch {

	public override StreamEnum stream_type {get { return StreamEnum.SEARCH; } }
	
	protected override string func {get; set; default = "search.atom";}
	
	public override string id {get; set; default = "search";}
	
	public string s_keyword {get; set; default= "";}
	
	construct {
		debug("twitter search stream was created");
		
		parsing_delegate = Parser.get_search;
	}
	
	protected override void set_call_params(bool more = false) {
		base.set_call_params(more);
		
		call.remove_param("q");
		call.add_param("q", s_keyword);//GLib.Uri.escape_string(s_keyword, "", true));//Soup.form_encode("", s_keyword).split("=")[1]);
	}
}

}
