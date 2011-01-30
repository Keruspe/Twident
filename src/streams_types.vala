using Gee;
using TwidentEnums;

/** Abstract class, holdes all available types of any streams */
public class StreamsTypes : HashMap<StreamEnum, StreamMeta> {

	public StreamsTypes() throws GLib.Error {
		Gtk.IconTheme theme = Gtk.IconTheme.get_default();
		
		Gdk.Pixbuf home_icon = theme.load_icon("go-home", 24, 0);
		StreamMeta home = new StreamMeta("Home", home_icon);
		set(StreamEnum.HOME, home);

		Gdk.Pixbuf mentions_icon = new Gdk.Pixbuf.from_file(Config.MENTIONS_PATH);
		StreamMeta mentions = new StreamMeta("Mentions", mentions_icon);
		set(StreamEnum.MENTIONS, mentions);
		
		Gdk.Pixbuf public_icon = theme.load_icon("applications-internet", 24, 0);
		StreamMeta public = new StreamMeta("Public", public_icon);
		set(StreamEnum.PUBLIC, public);
		
		Gdk.Pixbuf favorites_icon = theme.load_icon("gtk-about", 24, 0);
		StreamMeta favorites = new StreamMeta("Favorites", favorites_icon);
		set(StreamEnum.FAVORITES, favorites);
		
		Gdk.Pixbuf search_icon = theme.load_icon("gtk-find", 24, 0);
		StreamMeta search = new StreamMeta("Search", search_icon);
		set(StreamEnum.SEARCH, search);
		
		Gdk.Pixbuf group_icon = new Gdk.Pixbuf.from_file(Config.GROUP_PATH);
		StreamMeta group = new StreamMeta("Group", group_icon);
		set(StreamEnum.GROUP, group);
	}
	
	/** Return type by a string value */
	/*
	public virtual StreamMmeta? get_type_by_string(StreamEnum stype) {
		foreach(StreamMeta meta in keys) {
			if(get(meta).name == stype) {
				return tp;
			}
		}

		return null;
	}
	*/
}
