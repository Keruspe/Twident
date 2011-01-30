using Gee;
using PinoEnums;

namespace Identica {
	
public class StreamGroup : Twitter.StreamHome {

	public override StreamEnum stream_type {get { return StreamEnum.GROUP; } }
	
	protected override string func {get; set; default = "";}
	
	public override string id {get; set; default = "group";}
	
	public string s_group_name {get; set; default = "";}
	
	construct {
		debug("identica group stream was created");
	}
	
	protected override void set_call_params(bool more = false) {
		base.set_call_params(more);
		
		func = "statusnet/groups/timeline/" + s_group_name + ".xml";
		call.set_function(func);
	}
}
}
