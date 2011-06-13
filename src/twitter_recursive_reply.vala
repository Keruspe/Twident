using Rest;
using Gee;

namespace Twitter {

public class RecursiveReply : GLib.Object  {
	
	public signal void new_reply(Status status, string sid);
	
	private Rest.Proxy proxy;
	private string s_name = "";
	private Status fstatus;
	//private string stream_hash = "";
	
	public RecursiveReply(Rest.Proxy proxy, Status fstatus, string s_name) {
		
		this.proxy = proxy;
		this.fstatus = fstatus;
		this.s_name = s_name;
		//this.stream_hash = stream_hash;
	}
	
	public void run() {
		get_reply(fstatus);
	}
	
	private void get_reply(Status status) {
		if(status.reply == null) {
			fstatus.end_reply();
			return;
		}
		
		Rest.ProxyCall call = proxy.new_call();
		call.set_function("statuses/show/%s.xml".printf(status.reply.status_id));
		call.set_method("GET");
		Rest.ProxyCallAsyncCallback callback = status_get_respose;
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	protected void status_get_respose(Rest.ProxyCall call, Error? error, Object? obj) {
		Status? status = Parser.get_status_from_string(call.get_payload(), s_name);
		
		if(status == null)
			return;
		
		new_reply(status, fstatus.id);
		
		if(fstatus.conversation == null)
			fstatus.conversation = new ArrayList<Status>();
		
		fstatus.conversation.add(status);
		fstatus.new_reply(status); //signal
		
		get_reply(status);
	}
}
}
