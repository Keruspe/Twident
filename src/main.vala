using Gtk;
using Rest;
using Cairo;

public class TestWindow : Window {
	
	public TestWindow() {
		set_default_size(300, 200);
		/*
		Status status1 = new Status();
		status1.content = """This is a Vala port of the famous Egg Clock sample <a href="somelink"><b>@widget</b></a> using Cairo and GTK+ as <a href="link:action"><b>described</b></a> in the GNOME Journal: Part 1 and part 2""";
		status1.user = new User();
		status1.user.name = "SomeUser1";
		status1.user.pic = "http://a2.twimg.com/profile_images/30581162/bobuk_normal.png";
		
		Status status2 = new Status();
		status2.fresh = true;
		status2.content = """This is a Vala port of the famous Egg Clock sample <a href="somelink"><b>@widget</b></a> using Cairo and GTK+ as <a href="link:action"><b>described</b></a> in the GNOME Journal: Part 1 and part 2""";
		status2.user = new User();
		status2.user.name = "SomeUser2";
		status2.user.pic = "http://a0.twimg.com/profile_images/1139641176/omgubuntu_normal.png";
		
		Status status3 = new Status();
		status3.content = """This is a Vala port of the famous Egg Clock sample <a href="somelink"><b>@widget</b></a> using Cairo and GTK+ as <a href="link:action"><b>described</b></a> in the GNOME Journal: Part 1 and part 2""";
		status3.user = new User();
		status3.user.name = "SomeUser3";
		status3.user.pic = "http://a0.twimg.com/profile_images/185027712/_D0_A4_D0_B0_D0_B9_D0_BBTsar_nikolai_normal.jpg";
		
		Status status4 = new Status();
		status4.fresh = true;
		status4.content = """This is a Vala port of the famous Egg Clock sample <a href="somelink"><b>@widget</b></a> using Cairo and GTK+ as <a href="link:action"><b>described</b></a> in the GNOME Journal: Part 1 and part 2""";
		status4.user = new User();
		status4.user.name = "SomeUser4";
		status4.user.pic = "http://a3.twimg.com/profile_images/1120466363/Clipboard02_normal.png";
		
		FeedModel model = new FeedModel();
		model.add(status1);
		model.add(status2);
		model.add(status3);
		
		FeedView feed_view = new FeedView();
		feed_view.set_model(model);
		add(feed_view);
		
		show_all();
		
		model.insert(0, status4);
		//model.remove_at(1);
		
		status4.fresh = false;
		status3.fresh = true;
		*/
	}
}

public static int main (string[] args) {
	Gtk.init (ref args);
        GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
        GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);
	//globals
	img_cache = new ImgCache();
	
	try {
		accounts_types = new AccountsTypes();
		streams_types = new StreamsTypes();
		settings = new Settings();
	} catch(GLib.Error e) {
		debug(e.message); //TODO
	}
	
	//TestWindow w = new TestWindow();
	
	
	main_window = new MainWindow();
	/*
	string api_key = "469089ec99372ee016bebd30218f1b23";
	string app_secret = "09c8836c79ba2f7182273bfb706c58c0";
	
	FacebookProxy proxy = new FacebookProxy(api_key, app_secret);
	string session_key = FacebookProxy.get_session_key(proxy);
	debug(session_key);
	FacebookProxy.set_session_key(proxy, session_key);
	FacebookProxyCall call = (FacebookProxyCall) proxy.new_call();
	return 0;
	*/
	Gtk.main();
    
	return 0;
}

public void some_case(string? path) {
	if(path == null) {
		debug("null");
		return;
	}
	debug(path);
}
