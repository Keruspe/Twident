using Gtk;
using Cairo;

public class UpdatesCellRrenderer : CellRenderer {
	
	public string text {get; set;}
	
	private const int RADIUS = 5;
	private const double M_PI = 3.1415926535;
	private double MAX_RGB = (double) uint16.MAX;
	private const double TEXT_W_OFFSET = 6;
	private const double TEXT_H_OFFSET = 3;
	
	private int area_width = 40;
	
	construct {}
	
	public override void get_size(Gtk.Widget widget, Gdk.Rectangle? cell_area,
		out int x_offset, out int y_offset, out int width, out int height) {
		x_offset = 0;
		y_offset = 0;
		width = area_width;
		height = (cell_area == null) ? width : cell_area.height;
	}
  
	public override void render(Gdk.Window window, Gtk.Widget widget,
		Gdk.Rectangle background_area, Gdk.Rectangle cell_area,
		Gdk.Rectangle expose_area, Gtk.CellRendererState flags) {
		
		if(text.length == 0 || text == "0")
			return;
		
		Context ctx = Gdk.cairo_create(window);
		ctx.set_line_width(2);
		
		Style style = rc_get_style(widget);
		Gdk.Color bg_color;
		Gdk.Color fg_color;
		
		if(flags == CellRendererState.SELECTED || flags == 3) {
			bg_color = style.light[Gtk.StateType.NORMAL];
			fg_color = style.fg[Gtk.StateType.NORMAL];
		} else {
			bg_color = style.bg[Gtk.StateType.SELECTED];
			fg_color = style.fg[Gtk.StateType.SELECTED];
		}
		
		//text
		Pango.FontDescription font_desc = style.font_desc;
		double font_size = font_desc.get_size() / 1000.0 + 3;
		ctx.select_font_face(font_desc.get_family(), FontSlant.NORMAL, FontWeight.BOLD);
		ctx.set_font_size(font_size);
		
		//text margins
		TextExtents ex;
		ctx.text_extents(text, out ex);
		double text_width = ex.width;
		double text_height = ex.height;
		
		area_width = (int) (text_width + TEXT_W_OFFSET * 2);
		set_fixed_size(area_width, cell_area.height);
		
		//draw rect
		double height = text_height + TEXT_H_OFFSET * 2;
		double radius = height / 2.0;
		draw_rounded_rect(ctx, bg_color, cell_area.x,
			cell_area.y + (cell_area.height - height) / 2.0,
			text_width + TEXT_W_OFFSET * 2, height, radius);
		
		//draw text
		ctx.set_source_rgb(fg_color.red / MAX_RGB, fg_color.green / MAX_RGB,
			fg_color.blue / MAX_RGB);
		
		ctx.move_to(cell_area.x + TEXT_W_OFFSET, cell_area.y + (cell_area.height + text_height) / 2.0);
		ctx.show_text(text);
	}
	
	private void draw_rounded_rect(Context ctx, Gdk.Color bg_color, double x,
		double y, double width, double height, double radius) {
		
		double degrees = M_PI / 180.0;
		
		ctx.new_sub_path();
		ctx.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
		ctx.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
		ctx.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
		ctx.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
		ctx.close_path();
		
		//get rgb
		double r = (double) bg_color.red / MAX_RGB;
		double g = (double) bg_color.green / MAX_RGB;
		double b = (double) bg_color.blue / MAX_RGB;
		
		ctx.set_source_rgb(r, g, b);
		
		ctx.fill_preserve();
	}
}
