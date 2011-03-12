using Gtk;

public class VisualStyle : GLib.Object {
	
	public signal void changed();
	
	private Widget widget;
	
	public string bg_color {get; set;}
	public string bg_light_color {get; set;}
	public string fg_color {get; set;}
	public string lk_color {get; set;} //link color
	
	public string font_family {get; set;}
	public int font_size {get; set;}
	
	public VisualStyle(Widget widget) {
		this.widget = widget;
		
		widget.style_set.connect((prev_style) => { update_style(); });
	}
	
	private void update_style() {
		Style style = rc_get_style(widget);
		
		bg_color = rgb_to_hex(style.bg[Gtk.StateType.NORMAL]);
		bg_light_color = rgb_to_hex(style.light[Gtk.StateType.NORMAL]);
		fg_color = rgb_to_hex(style.fg[Gtk.StateType.NORMAL]);
		
		Value? v = Value(typeof(Gdk.Color));
		if(v != null) {
			lk_color = rgb_to_hex((Gdk.Color) v);
			debug(lk_color);
		}
		
		font_family = style.font_desc.get_family();
		font_size = style.font_desc.get_size() / 1000;
		
		changed(); //emit signal
		
		//return true;
	}
	
	private string rgb_to_hex(Gdk.Color color) {
		string s = "%X%X%X".printf(
			(int)Math.trunc(color.red / 256.00),
			(int)Math.trunc(color.green / 256.00),
			(int)Math.trunc(color.blue / 256.00));
		return "#" + s;
	}
}
