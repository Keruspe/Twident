<div class="status">
	<a href="userinfo://{{screen_name}}"><div class="avatar" style="background-image:url('{{avatar}}');"></div></a>
	<div class="content_{{fresh}}" id="{{id}}">
		<div class="header">
			<a class="nick" href="nickto://{{screen_name}}">{{name}}</a>
			<span class="date">{{time}}</span>
		</div>
		<div class="{{rtl_class}}">
			{{content}}
		</div>
		<div class="footer">
			<span>&nbsp;</span><span class="footer-right"><a class="reply" title="{{dm_text}}" href="directreply://{{screen_name}}"><img src="{{direct_reply}}" /></a><a class="reply" title="{{delete_text}}" href="delete://{{id}}"><img src="{{delete}}" /></a></span>
		</div>
	</div>
</div>
