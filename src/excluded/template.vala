using Gee;
using PinoEnums;

public class Template : Object {
	
	private VisualStyle visual_style;
	
	private string main_tpl = """
		<html>
			<head>
			<script type="text/javascript">
			function insertAfter(newElement,targetElement) {
				var parent = targetElement.parentNode;
				if(parent.lastchild == targetElement) {
					parent.appendChild(newElement);
				} else {
					parent.insertBefore(newElement, targetElement.nextSibling);
				}
			}
			function insert_reply(status_id, data) {
				var footer = document.getElementById("footer" + status_id);
				footer.removeAttribute("href");
				
				var reply = document.getElementById("reply" + status_id);
				
				if(reply == null) {
					reply = document.createElement("div");
					reply.setAttribute("class", "reply-box");
					reply.setAttribute("id", "reply" + status_id);
				}
				
				reply.innerHTML += data;
				
				var status = document.getElementById("status" + status_id);
				//alert(status);
				insertAfter(reply, status);
			}
			function change_style(data) {
				document.getElementById("style").innerHTML = data;
			}
			function set_content(data) {
				document.getElementById("body").innerHTML = data;
			}
			function menu(e, data) {
				if(e.button == 2) {
					location.href="contextmenu://" + data;
					return true;
				}
			}
			function reply(e, data) {
				var sel = window.getSelection();
				sel.removeAllRanges();
				location.href="reply://" + data;
				return true;
			}
			</script>
			<style type="text/css" id="style">
			</style>
			</head>
			<body id="body">
			%s
			</body>
		</html>
	""";
	
	/*
	private string header_tpl = """
		<style type="text/css">
	body {
  		color: {{fg_color}};
  		#font-family: Droid Sans;
  		#font-size: 9pt;
  	}
  	.status, .status-fresh {
  		margin-bottom: 10px;
  	}
	.tri {
		z-index: 3;
		position: absolute;
		top: 16px;
		left: 0px;
		width: 14px;
		height: 14px;
		background-color: {{bg_color}};
		border: 1px solid #ddd;
		border-right-style: none;
		border-top-style: none;
		-webkit-transform: rotate(45deg);
		-webkit-border-radius: 0px 0px 0px 2px;
		-webkit-box-shadow: 0px 1px 1px  #ccc;
	}
	.line {
		z-index: 5;
		position: absolute;
		background-color: {{bg_color}};
		top: 14px;
		left: 7px;
		width: 1px;
		height: 19px;
		-webkit-border-radius: 3px;
	}
	.status-content {
		z-index: 4;
		position: relative;
		background-color: {{bg_color}};
		border: 1px solid #ddd;
		-webkit-border-radius: 3px;
		padding: 6px;
		margin-left: 7px;
		-webkit-box-shadow: 1px 1px 1px  #ccc;
		cursor: default;
	}
	a {
		color: {{lk_color}};
	}
	.tags {
		font-weight: bold;
		text-decoration: none;
	}
	.status-fresh .status-content {
		border-width: 2px;
		border-color: #478bde;
	}
	.status-fresh .tri {
		border-width: 2px;
		border-color: #478bde;
	}
	.status-fresh .line {
		top: 16px;
		height: 16px;
		width: 2px;
	}
	.status-own .tri {
		position: relative;
		float: right;
		-webkit-border-radius: 0px 2px 0px 0px;
		-webkit-box-shadow: 1px 0px 1px  #ccc;
	}
	.status-own .line {
		position: relative;
		float: right;
		width: 3px;
		left: 10px;
		#background-color: red;
	}
	.status-own .status-content {
		margin-left: 0px;
		margin-right: 7px;
	}
	.status-own .right {
		margin-left: 0px;
		margin-right: 58px;
	}
	.status-own .left {
		float: right;
	}
	.right {
		position:relative;
		margin-bottom: 10px;
		margin-left: 58px;
	}
	.left {
		float: left;
		width: 48px;
		height: 48px;
		backgrond-color: #fff;
		-webkit-border-radius: 3px;
		-webkit-background-size: 48px 48px;
		-webkit-box-shadow: 1px 1px 1px  #ccc;
	}
	.header {
		margin-bottom: 3px;
	}
	.header a, .re_nick {
		font-weight: bold;
		text-decoration: none;
		color: {{fg_color}};
		text-shadow: 1px 1px 0 #fff;
	}
	.date, .footer {
		font-size: smaller;
		font-weight: bold;
		text-shadow: 1px 1px 0 #fff;
		opacity: 0.6;
		float: right;
	}
	.footer {
		float: none;
		display: block;
		text-decoration: none;
		margin-top: 3px;
		color: {{fg_color}};
	}
	.rt {
		background-color: {{fg_color}};
		color: {{bg_color}};
		opacity: 0.6;
		margin-right: 2px;
		font-weight: bold;
		padding-left: 3px;
		padding-right: 3px;
		-webkit-border-radius: 3px;
	}
	.menu {
		background-color: {{fg_color}};
		opacity: 0.0;
		width: 15px;
		height: 15px;
		float: right;
		#margin-left: 3px;
		margin-top: -9px;
		#margin-bottom: 5px;
		margin-right: -6px;
		-webkit-border-radius: 3px 0 3px 0;
	}
	@-webkit-keyframes menu-hover {
		from {
			opacity: 0.0;
		}
		to {
			opacity: 0.6;
		}
	}
	.status-content:hover .menu {
		opacity: 0.6;
		-webkit-animation-name: menu-hover;
		-webkit-animation-duration: 1s;
	}
		</style>
	""";
	*/
	
	private string header_tpl = """
	body {
  		color: {{fg_color}};
  		background: {{bg_color}};
  		#font-family: Droid Sans;
  		#font-size: 9pt;
  		margin: 0px;
  	}
  	.status, .status-fresh, .status-own, .status-small {
		background: {{bg_light_color}};
  		padding: 6px;
  		position: relative;
  		min-height: 50px;
  		border: 0px solid #edeceb;
		border-bottom-width: 1px;
  	}
  	.status-small {
		border-left-width: 1px;
		-webkit-border-radius: 3px 0px 0px 3px;
		min-height: 30px;
	}
	.status-content {
		z-index: 4;
		position: relative;
		margin-left: 7px;
		cursor: default;
	}
	a {
		color: {{lk_color}};
	}
	.tags {
		font-weight: bold;
		text-decoration: none;
	}
	.reply-box {
		margin-left: 24px;
	}
	.status-fresh {
		#background: #c3dff7;
		background: -webkit-gradient(linear, 0 -75, 0 bottom, from({{bg_light_color}}), to(#c6ebb1));
		border: 0px;
	}
	.status-own .status-content {
		margin-left: 0px;
		margin-right: 7px;
	}
	.status-own .right {
		margin-left: 0px;
		margin-right: 50px;
	}
	.status-own .left {
		float: right;
	}
	.right {
		position:relative;
		margin-left: 50px;
	}
	.status-small .right {
			margin-left: 24px;
	}
	.left {
		float: left;
		width: 48px;
		height: 48px;
		backgrond-color: #fff;
		-webkit-border-radius: 3px;
		-webkit-background-size: 48px 48px;
		-webkit-box-shadow: 1px 1px 1px  #ccc;
	}
	.status-small .left {
		width: 24px;
		height: 24px;
		-webkit-background-size: 24px 24px;
	}
	.header {
		margin-bottom: 3px;
	}
	.header a, .re_nick {
		font-weight: bold;
		text-decoration: none;
		color: #404040;
		text-shadow: 1px 1px 0 #fff;
	}
	.date, .footer {
		font-size: smaller;
		font-weight: bold;
		text-shadow: 1px 1px 0 #fff;
		opacity: 0.6;
		float: right;
	}
	.status-own .header a {
		float: right;
	}
	.status-own .header .date {
		float: none;
	}
	.footer {
		float: none;
		#display: block;
		text-decoration: none;
		padding-top: 5px;
		color: #404040;
	}
	.sep{
		height: 6px;
	}
	.rt {
		background-color: #404040;
		color: #FCFBFA;
		opacity: 0.6;
		margin-right: 2px;
		font-weight: bold;Goldman Sachs
		padding-left: 3px;
		padding-right: 3px;
		-webkit-border-radius: 3px;
	}
	.menu {
		background-color: #404040;
		opacity: 0.0;
		width: 15px;
		height: 15px;
		float: right;
		margin-top: -9px;
		margin-right: -6px;
		-webkit-border-radius: 3px 0 3px 0;
	}
	.clear {
		clear: both;
	}
	@-webkit-keyframes menu-hover {
		from {
			opacity: 0.0;
		}
		to {
			opacity: 0.6;
		}
	}
	.status-content:hover .menu {
		opacity: 0.6;
		-webkit-animation-name: menu-hover;
		-webkit-animation-duration: 1s;
	}
	""";
	
	/*
	private string status_tpl = """
	<div class="status{{status_state}}">
		<div class="left" style="background-image:url('{{user_pic}}');"></div>
	 	<div class="right">
	 		<div class="tri"></div>
	 		<div class="line"></div>
			<div class="status-content">
			<div class="header">
				{{retweet}} <a href="">{{user_name}}</a>
				<span class="date">about one hour ago</span>
			</div>
			<div>{{content}}</div>
			{{footer}}
			<a href=""><div class="menu"></div></a>
			</div>
		</div>
	</div>
	""";
	*/
	
	private string status_tpl = """
	<div class="status{{status_state}}" id="status{{status_id}}" onmouseup="menu(event, '{{account_hash}}##{{stream_hash}}##{{status_id}}');" ondblclick="reply(event, '{{account_hash}}##{{stream_hash}}##{{status_id}}');">
		<div class="left" style="background-image:url('{{user_pic}}');"></div>
	 	<div class="right">
			<div class="status-content">
				<div class="header">
					{{retweet}} <a href="">{{user_name}}</a>
					<span class="date">{{created}}</span>
				</div>
				<div>{{content}}</div>
				{{footer}}
			</div>
		</div>
		<div class="clear"></div>
	</div>
	""";
	
	private string status_small_tpl = """
	<div class="status-small">
		<div class="left" style="background-image:url({{user_pic}});"></div>
		<div class="right">
			<div class="status-content">
				<a class="re_nick" href="">{{user_name}}</a>: {{content}}
			</div>
		</div>
		<div class="clear"></div>
	</div>
	""";
	
	private string retweet_tpl = """<span class="rt">Rt:</span>""";
	private string footer_tpl = """<div class="sep"></div><a class="footer" id="footer{{status_id}}" href="context://{{account_hash}}##{{stream_hash}}##{{status_id}}">%s</a>""";
	
	private string header;
	
	private Regex nicks;
	private Regex tags;
	private Regex groups;
	private Regex urls;
	private Regex clear_notice;
	
	public Template(VisualStyle visual_style) {
		this.visual_style = visual_style;
		
		render_header();
		
		nicks = new Regex("(^|\\s|['\"+&!/\\(-])@([A-Za-z0-9_]+)");
		tags = new Regex("(^|\\s|['\"+&!/\\(-])#([A-Za-z0-9_.-\\p{Latin}\\p{Greek}]+)");
		groups = new Regex("(^|\\s|['\"+&!/\\(-])!([A-Za-z0-9_]+)"); //for identi.ca groups
		urls = new Regex("((https?|ftp)://([A-Za-z0-9+&@#/%?=~_|!:,.;-]*)([A-Za-z0-9+&@#/%=~_|$]))"); // still needs to be improved for urls containing () such as wikipedia's
		
		// characters must be cleared to know direction of text
		clear_notice = new Regex("[: \n\t\r♻♺]+|@[^ ]+");
	}
	
	public string stream_to_list(AStream stream, string hash) {
		//changing locale to C
		string currentLocale = GLib.Intl.setlocale(GLib.LocaleCategory.TIME, null);
		GLib.Intl.setlocale(GLib.LocaleCategory.TIME, "C");
		
		string result = "";
		
		foreach(Status status in stream.statuses_fresh) {
			result += render_fresh_status(status, stream);
		}
		
		foreach(Status status in stream.statuses) {
			result += render_status(status, stream);
		}
		
		//string main_result = main_tpl.printf(header, result);
		//debug(main_result);
		
		//back to the normal locale
		GLib.Intl.setlocale(GLib.LocaleCategory.TIME, currentLocale);
		
		return result;
	}
	
	public string render_body() {
		return main_tpl.printf("");
	}
	
	public string render_header() {
		HashMap<string, string> map = new HashMap<string, string>();
		map["fg_color"] = visual_style.fg_color;
		map["bg_color"] = visual_style.bg_color;
		map["bg_light_color"] = visual_style.bg_light_color;
		map["lk_color"] = visual_style.lk_color;
		header = render(header_tpl, map);
		return header;
	}
	
	public string render_fresh_status(Status status, AStream stream) {
		HashMap<string, string> map = new HashMap<string, string>();
		map["status_state"] = "-fresh";
		return render_status(status,stream,  map);
	}
	
	public string render_status(Status status,
		AStream stream, HashMap<string, string> map = new HashMap<string, string>()) {
		
		Status wstatus = status;
		map["retweet"] = "";
		map["footer"] = "";
		
		if(status.retweet != null) { //if this status is retweet
			wstatus = status.retweet;
			map["retweet"] = retweet_tpl;
			
			string re_by = _("retweeted by ") + status.user.name;
			map["footer"] = footer_tpl.printf(re_by);
		}
		
		if(status.reply != null) { //if we have reply here
			string reply_to = _("in reply to ") + status.reply.name;
			map["footer"] = footer_tpl.printf(reply_to);
		}
		
		if(!map.has_key("status_state")) //if not fresh
			map["status_state"] = "";
		
		if(wstatus.own) //if it your own status
			map["status_state"] = "-own";
		
		if(img_cache.exist(wstatus.user.pic)) //load from cache, if exist
			map["user_pic"] = img_cache.download(wstatus.user.pic);
		else
			map["user_pic"] = wstatus.user.pic;
		
		map["user_name"] = wstatus.user.name;
		
		bool is_search = false;
		if(stream.stream_type == StreamEnum.SEARCH)
			is_search = true;
		
		map["created"] = time_to_human_delta(wstatus.created, is_search);
		
		map["content"] = format_content(wstatus.content, stream);
		
		//context menu data
		map["account_hash"] = stream.account.get_hash();
		map["stream_hash"] = stream.account.get_stream_hash(stream);
		map["status_id"] = status.id;
		
		return render(status_tpl, map);
	}
	
	public string render_small_status(Status status, AStream stream) {
		HashMap<string, string> map = new HashMap<string, string>();
		if(img_cache.exist(status.user.pic)) //load from cache, if exist
			map["user_pic"] = img_cache.download(status.user.pic);
		else
			map["user_pic"] = status.user.pic;
		
		
		map["user_name"] = status.user.name;
		map["content"] = format_content(status.content, stream);
		
		return render(status_small_tpl, map);
	}
	
	private string render(string text, HashMap<string, string> map) {
		string result = text;
		
		foreach(string key in map.keys) {
			var pat = new Regex("{{" + key + "}}");
			result = pat.replace(result, -1, 0, map[key]);
		}
		//debug(result);
		return result;
	}
	
	/* Performaing to show in html context */
	private string strip_tags_plus(owned string content) {
		content = content.replace("\\", "&#92;");
		//content = Markup.escape_text(content);
		content = content.replace("<", "&lt;");
		content = content.replace(">", "&gt;");
		
		return content;
	}
	
	private string format_content(owned string data, AStream stream) {
		data = strip_tags_plus(data);
		
		string tmp = data;
		
		int pos = 0;
		while(true) {
			//url cutting
			MatchInfo match_info;
			bool bingo = urls.match_all_full(tmp, -1, pos, GLib.RegexMatchFlags.NEWLINE_ANY, out match_info);
			if(bingo) {
				foreach(string s in match_info.fetch_all()) {
					if(s.length > 30) {
						data = data.replace(s, """<a href="%s" title="%s">%s...</a>""".printf(s, s, s.substring(0, 30)));
					} else {
						data = data.replace(s, """<a href="%s">%s</a>""".printf(s, s));
					}
					
					match_info.fetch_pos(0, null, out pos);
					break;
				}
			} else break;
		}
		
		data = nicks.replace(data, -1, 0, "\\1@<a class='re_nick' href='userinfo://\\2'>\\2</a>");
		data = tags.replace(data, -1, 0, "\\1#<a class='tags' href='search://%s::\\2'>\\2</a>".printf(stream.account.get_stream_hash(stream)));
		
		data = groups.replace(data, -1, 0, "\\1!<a class='tags' href='http://identi.ca/group/\\2'>\\2</a>");
		
		return data;
	}
	
	private string time_to_human_delta(string created, bool is_search = false) {
		int delta = TimeParser.time_to_diff(created, is_search);
		
		if(delta < 30)
			return _("a few seconds ago");
		if(delta < 120)
			return _("1 minute ago");
		if(delta < 3600)
			return _("%i minutes ago").printf(delta / 60);
		if(delta < 7200)
			return _("about 1 hour ago");
		if(delta < 86400)
			return _("about %i hours ago").printf(delta / 3600);
		
		return TimeUtils.str_to_time(created).format("%k:%M %b %d %Y");
	}
}
