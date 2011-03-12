using Gee;
using TwidentEnums;
using Rest;

namespace Twitter {

public abstract class StreamAbstract : AStream {
	
	protected Rest.Proxy proxy;
	protected string own_name = "";
	//protected string auth_header;
	protected Rest.ProxyCall call;
	
	protected abstract string func {get; set;}
	
	protected virtual void set_call_params(bool more = false) {}
	
	protected abstract void parse_stream(string data);
	protected abstract void parse_more_stream(string data);
	
	public virtual void set_proxy(Rest.Proxy proxy, string own_name, string password = "") {
		this.proxy = proxy;
		this.own_name = own_name;
		
		debug("proxy was added");
		
		//setup call
		call = proxy.new_call();
		call.set_function(func);
		call.set_method("GET");
		
		if(password != "") { //creating basic http auth header
			uchar[] b_chars = Utils.string_to_uchar_array("%s:%s".printf(own_name, password));
			string http_auth = GLib.Base64.encode(b_chars);
			call.add_header("Authorization", "Basic %s".printf(http_auth));
		}
		
		sync();
	}
	
	public virtual void sync(bool more = false) {
		if(status == StreamStatus.UPDATING || status == StreamStatus.PARSING)
			return;
		/*
		try {
			thread = Thread.create(sync_thread, true);
		} catch(ThreadError e) {
			debug(e.message);
		}*/
		debug(func);
		debug("start updating");
		status = StreamStatus.UPDATING;
		
		Rest.ProxyCallAsyncCallback callback;
		
		if(more)
			callback = (ProxyCallAsyncCallback) get_more_response;
		else
			callback = (ProxyCallAsyncCallback) get_response;
		
		set_call_params(more);
		try {
			call.run_async(callback, this);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
	
	public void get_response(Rest.ProxyCall call, Error? error, Object? obj) {
		debug("finish updating");
		status = StreamStatus.READY;
		//debug(call.get_payload());
		parse_stream(call.get_payload());
		
		updated(); //emit signal
	}
	
	public void get_more_response(Rest.ProxyCall call, Error? error, Object? obj) {
		debug("finish updating");
		status = StreamStatus.READY;
		//debug(call.get_payload());
		parse_more_stream(call.get_payload());
		
		updated(); //emit signal
	}
	
	public override void menu_refresh() {
		debug("twitter sync");
		sync();
	}
}

}
