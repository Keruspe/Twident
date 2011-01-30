using Gee;
using PinoEnums;

/**
 * Holder all properties of existing streams in account
 */
public class StreamState : HashMap<string, string> {

	public StreamEnum stream_type {get; set;}
	
	public StreamState(StreamEnum stream_type) {
		this.stream_type = stream_type;
	}
}
