using Gee;

public class AccountMeta : Object {

	public string name {get; set;}
	public string description {get; set;}
	public Gdk.Pixbuf icon {get; set;}
	public string icon_name {get; set;}

	public AccountMeta(string name, string description, Gdk.Pixbuf icon,
		string icon_name) {
		
		this.name = name;
		this.description = description;
		this.icon = icon;
		this.icon_name = icon_name;
	}
	
}

/** Holdes all available types of accounts.
	Icons http://paulrobertlloyd.com/2009/06/social_media_icons.
	Licenced under an Attribution-Share Alike 2.0 UK: England & Wales Licence
*/
public class AccountsTypes : HashMap<Type, AccountMeta> {
	
	public AccountsTypes() throws GLib.Error {
		AccountMeta twitter = new AccountMeta("Twitter",
			"Most popular microblogging service in the world",
			new Gdk.Pixbuf.from_file(Config.SERVICE_TWITTER_ICON),
			Config.SERVICE_TWITTER_ICON);
		
		AccountMeta identica = new AccountMeta("Identica",
			"Most popular microblogging service in the world",
			new Gdk.Pixbuf.from_file(Config.SERVICE_IDENTICA_ICON),
			Config.SERVICE_IDENTICA_ICON);
		
		set(typeof(Twitter.Account), twitter);
		set(typeof(Identica.Account), identica);
	}

	/** Return type by a string value */
	public Type? get_type_by_string(string stype) {
		foreach(Type tp in keys) {
			if(get(tp).name == stype) {
				return tp;
			}
		}

		return null;
	}
}

