using Gtk;
using Cairo;

public class IconWithStatusCellRrenderer : CellRenderer {
	
	private const double TEXT_W_OFFSET = 6;
	private const double TEXT_H_OFFSET = 3;
	private double MAX_RGB = (double) uint16.MAX;
	private const int RADIUS = 5;
	private const double M_PI = 3.1415926535;
	
	private Gdk.Pixbuf? _icon = null;
	private Gdk.Pixbuf? _status_icon = null;
	private string? _text = "unknown";
	private string? _updates = null;
	private bool _border = false;
	public MetaRow meta_row {
		set {
			_icon = value.icon;
			if(_icon != null && (_icon.width > ICON_SIZE || _icon.height > ICON_SIZE)) { //scale icon to ICON_SIZE
				_icon = _icon.scale_simple(ICON_SIZE, ICON_SIZE,
					Gdk.InterpType.BILINEAR);
			}
			
			_status_icon = value.status_icon;
			if(_status_icon != null && (_status_icon.width > SMALL_ICON_SIZE ||
				_status_icon.height > SMALL_ICON_SIZE)) {
				
				_status_icon = _status_icon.scale_simple(SMALL_ICON_SIZE,
					SMALL_ICON_SIZE, Gdk.InterpType.BILINEAR);
			}
			
			
			_text = value.text;
			
			if(value.updates != null && value.updates > 0)
				_updates = value.updates.to_string();
			else
				_updates = "";
			
			_border = value.acc;
		}
	}
	
	private const int ICON_SIZE = 24;
	private const int SMALL_ICON_SIZE = 12;
	private const int ICON_OFFSET = 2;
	
	construct {}
	
	public override void get_size(Gtk.Widget widget, Gdk.Rectangle? cell_area,
		out int x_offset, out int y_offset, out int width, out int height) {
	
		if(&x_offset != null) x_offset = 0;
		if(&y_offset != null) y_offset = 0;
		if(&width != null) width = ICON_SIZE + 100;
		if(&height != null) height = ICON_SIZE;
		
		return;
	}
  
	public override void render(Gdk.Window window, Gtk.Widget widget,
		Gdk.Rectangle background_area, Gdk.Rectangle cell_area,
		Gdk.Rectangle expose_area, Gtk.CellRendererState flags) {
		
		Context ctx = Gdk.cairo_create(window);
		if (&expose_area != null) {
			Gdk.cairo_rectangle(ctx, expose_area);
			ctx.clip();
		}
		
		Style style = rc_get_style(widget);
		
		/*
		//border
		if(_border) {
		Gdk.Rectangle border_rect = {cell_area.x, cell_area.y, ICON_SIZE, ICON_SIZE};
		Gdk.Color f_color = style.bg[Gtk.StateType.NORMAL];
		Gdk.Color b_color = {1, 187 * 257, 190 * 257, 183 * 257};
		ctx.set_line_width(1.0);
		draw_rounded_rect(ctx, f_color, cell_area.x, cell_area.y, ICON_SIZE,
			ICON_SIZE, 2, true, b_color);
		}*/
		
		//main icon
		if(_icon != null) {
			Gdk.Rectangle big_rect = {cell_area.x, cell_area.y , ICON_SIZE, ICON_SIZE};
			Gdk.cairo_rectangle(ctx, big_rect);
			Gdk.cairo_set_source_pixbuf (ctx, _icon, big_rect.x,
				big_rect.y);
		
			ctx.fill();
		}
		
		//status or service type icon
		if(_status_icon != null) {
			Gdk.Rectangle small_rect = {cell_area.x + _icon.width - SMALL_ICON_SIZE,
				cell_area.y + _icon.height - SMALL_ICON_SIZE,
				SMALL_ICON_SIZE, SMALL_ICON_SIZE};
			
			Gdk.cairo_rectangle(ctx, small_rect);
			Gdk.cairo_set_source_pixbuf (ctx, _status_icon, small_rect.x,
				small_rect.y);
			
			ctx.fill();
		}
		
		Pango.FontDescription font_desc = style.font_desc;
		//double dpi = (Gdk.Screen.get_default()).get_resolution();
		//double font_size = font_desc.get_size() * dpi / 72.0 / 1000.0;
		
		Gdk.Color fg_color;
		Gdk.Color bg_color;
		
		double text_width_u = 0;
		
		if(_updates != null && _updates != "") {
			ctx.select_font_face(font_desc.get_family(), FontSlant.NORMAL, FontWeight.BOLD);
			
			if(flags == CellRendererState.SELECTED || flags == 3) {
				bg_color = style.light[Gtk.StateType.NORMAL];
				fg_color = style.fg[Gtk.StateType.NORMAL];
			} else {
				bg_color = style.bg[Gtk.StateType.SELECTED];
				fg_color = style.fg[Gtk.StateType.SELECTED];
			}
			
			//text margins
			TextExtents ex_up;
			ctx.text_extents(_updates, out ex_up);
			text_width_u = ex_up.width;
			double text_height_u = ex_up.height;
		
			int area_width = (int) (text_width_u + TEXT_W_OFFSET * 2);
			set_fixed_size(area_width, cell_area.height);
		
			//draw rect
			double height = text_height_u + TEXT_H_OFFSET * 2;
			double radius = height / 2.0;
			double rect_w = text_width_u + TEXT_W_OFFSET * 2;
			draw_rounded_rect(ctx, bg_color, cell_area.x + cell_area.width - rect_w,
				cell_area.y + (cell_area.height - height) / 2.0,
				rect_w, height, radius);
		
			//draw text
			ctx.set_source_rgb(fg_color.red / MAX_RGB, fg_color.green / MAX_RGB,
				fg_color.blue / MAX_RGB);
		
			ctx.move_to(cell_area.x - TEXT_W_OFFSET + cell_area.width - text_width_u,
				cell_area.y + (cell_area.height + text_height_u) / 2.0);
			ctx.show_text(_updates);
		}
		
		//text
		if(_text != null) {
			/*
			ctx.select_font_face(font_desc.get_family(), FontSlant.NORMAL, FontWeight.NORMAL);
			ctx.set_font_size(font_size);
			
			//text margins
			TextExtents ex;
			ctx.text_extents(_text, out ex);
			double text_width = ex.width;
			double text_height = ex.height;
			
			int i = 1;
			while(true) {
				ctx.text_extents(dr_text, out ex);
				text_width = ex.width;
				if(text_width + ICON_SIZE + TEXT_W_OFFSET * 4 + text_width_u > cell_area.width) {
					//if(i >= _
					dr_text = _text.substring(0, dr_text.length - i - 1);
				}
				else
					break;
			}
			
			int area_width = (int) (text_width + TEXT_W_OFFSET * 2);
			set_fixed_size(area_width, cell_area.height);
			
			
			if(flags == CellRendererState.SELECTED || flags == 3) {
				fg_color = style.fg[Gtk.StateType.SELECTED];
			} else {
				fg_color = style.fg[Gtk.StateType.NORMAL];
			}
			
			ctx.set_source_rgb(fg_color.red / MAX_RGB, fg_color.green / MAX_RGB,
				fg_color.blue / MAX_RGB);
			
			ctx.move_to(cell_area.x + ICON_SIZE + TEXT_W_OFFSET,
				cell_area.y + (cell_area.height + text_height) / 2.0);
			ctx.show_text(dr_text);*/
			
			//text margins
			TextExtents ex;
			ctx.text_extents(_text, out ex);
			//double text_width = ex.width;
			double text_height = ex.height;
			
			var layout = new Pango.Layout(widget.get_pango_context());
			layout.set_text(_text, (int) _text.length);
			//layout.set_wrap(Pango.WrapMode.CHAR);
			//layout.set_ellipsize(Pango.EllipsizeMode.END);
			//int t_w = 0;
			//layout.get_pixel_size(out t_w, null);
			//layout.set_width(t_w);
			
			widget.get_style().draw_layout(window, StateType.NORMAL, false,
				cell_area, widget, "cellrenderertext", (int) (cell_area.x + ICON_SIZE + TEXT_W_OFFSET),
				(int) (cell_area.y + (text_height) / 2.0), layout);
		}
	}
	
	private void draw_rounded_rect(Context ctx, Gdk.Color bg_color, double x,
		double y, double width, double height, double radius, bool stroke = false,
		Gdk.Color? border_color = null) {
		
		double degrees = M_PI / 180.0;
		
		ctx.new_sub_path();
		ctx.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
		ctx.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
		ctx.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
		ctx.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
		ctx.close_path();
		
		set_color(ctx, bg_color);
		
		ctx.fill_preserve();
		
		if(stroke) {
			set_color(ctx, border_color);
			ctx.stroke_preserve();
		}
	}
	
	private void set_color(Context ctx, Gdk.Color color) {
		//get rgb
		double r = (double) color.red / MAX_RGB;
		double g = (double) color.green / MAX_RGB;
		double b = (double) color.blue / MAX_RGB;
		
		ctx.set_source_rgb(r, g, b);
	}
}
