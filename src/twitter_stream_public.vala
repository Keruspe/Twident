using Gee;
using TwidentEnums;

namespace Twitter {

public class StreamPublic : Twitter.StreamHome {

	public override StreamEnum stream_type {get { return StreamEnum.PUBLIC; } }
	
	protected override string func {get; set; default = "statuses/public_timeline.xml";}
	
	public override string id {get; set; default = "public";}
	
	construct {
		debug("twitter public stream was created");
	}
}

}
