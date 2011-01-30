using Gee;
using PinoEnums;

namespace Twitter {

public class StreamMentions : Twitter.StreamHome {

	public override StreamEnum stream_type {get { return StreamEnum.MENTIONS; } }
	
	protected override string func {get; set; default = "statuses/mentions.xml";}
	
	public override string id {get; set; default = "mentions";}
	
	construct {
		debug("twitter mentions stream was created");
	}
}

}
