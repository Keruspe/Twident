/** All search streams must implement this interface */
public interface ISearch : GLib.Object {
	
	public abstract string s_keyword {get; set;}
}
