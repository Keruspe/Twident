public class MetaRow : Object {
	
	public Gdk.Pixbuf? icon {get; set;}
	public Gdk.Pixbuf? status_icon {get; set; default = null;}
	public string? text {get; set; default = "unknown";}
	public int? updates {get; set; default = null;}
	public bool acc {get; set; default = false;}
	
	public MetaRow(Gdk.Pixbuf? icon = null, Gdk.Pixbuf? status_icon = null,
		string? text = null, bool acc = false, int? updates = null) {
		
		this.icon = icon;
		this.status_icon = status_icon;
		this.text = text;
		this.updates = updates;
		this.acc = acc;
	}
}
