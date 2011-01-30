<div class="status">
	<a href="userinfo://{{screen_name}}"><div class="avatar" style="background-image:url('{{avatar}}');"></div></a>
	<div class="content_{{fresh}}" id="{{id}}">
		<div class="header">
			{{re_icon}}<a class="nick" href="nickto://{{screen_name}}">{{name}}</a>
			{{favorite}}</a><span class="date">{{time}}</span>
		</div>
		<div class="{{rtl_class}}">
			{{content}}
		</div>
		<div class="footer">
			<span>{{by_who}}&nbsp;</span><span class="footer-right"><a title="{{dm_text}}" href="directreply://{{screen_name}}"><img src="{{direct_reply}}" /></a><a class="reply" title="{{reply_text}}" href="replyto://{{id}}"><img src="{{reply}}" /></a><a class="reply" title="{{retweet_text}}" href="retweet://{{id}}"><img src="{{re_tweet}}" /></a></span>
		</div>
	</div>
</div>
