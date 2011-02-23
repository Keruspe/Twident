using Gtk;
using Cairo;


/** Just for custom background */
public class BgBox : HBox {
	
	public bool fresh {get; set; default = false;}
	public bool favorited {get; set; default = false;}
	
	//it's not actualy true colors, like in Gdk
	private Gdk.Color color_fresh;
	private Gdk.Color color_favorited;
	
	public BgBox(bool homogeneous, int spacing) {
		GLib.Object(homogeneous: homogeneous, spacing: spacing);
		
		color_fresh = {1, 233, 249, 234};
		color_favorited = {1, 243, 237, 121};
		
		//when we fresh or not
		notify["fresh"].connect((s) => {
			redraw();
		});
		
		//when we favorited or not
		notify["favorited"].connect((s) => {
			redraw();
		});
	}
	
	public override bool expose_event(Gdk.EventExpose event) {
		if(fresh && !favorited)
			draw_background(color_fresh);
		
		if(favorited)
			draw_background(color_favorited);
		
		base.expose_event(event);
		
		return false;
	}
	
	private void draw_background(Gdk.Color color) {
		Context ctx = Gdk.cairo_create(this.window);
			
		Allocation alloc;
		get_allocation(out alloc);
		
		Gdk.cairo_rectangle(ctx, {0, 0, alloc.width, alloc.height});
		
		Cairo.Pattern grad = new Cairo.Pattern.linear(10, 0, 10, alloc.height);
		grad.add_color_stop_rgb(0, 1, 1, 1);
		
		grad.add_color_stop_rgb(1, color.red/256.0, color.green/256.0, color.blue/256.0);
		ctx.set_source(grad);
		
		ctx.fill();
	}
	
	private void redraw() {
		if (null == this.window)
			return;

		unowned Gdk.Region region = this.window.get_clip_region ();
		this.window.invalidate_region (region, true);
		this.window.process_updates (true);
    }
}
