using Gtk;
using Cairo;

/** Special class for avatars. With rounded corners and shadows */
public class Avatar : Image {
        
        public string url {get; set; default = "";}
        public int pix_size {get; set; default = 1;}
        
        public static const double M_PI = 3.1415926535;
        
        private bool active = true;
        private Gdk.Pixbuf? ipixbuf = null;
        private Gdk.Pixbuf? cpixbuf = null;

        private unowned Thread<void*>? thread = null;
        
        public Avatar(int pix_size) {
                GLib.Object();
                this.pix_size = pix_size;
                set_size_request(pix_size, pix_size);
        }
        
        public Avatar.from_url(string url, int pix_size) {
                this.url = url;
                this.pix_size = pix_size;
                
                set_size_request(pix_size, pix_size);
                
                load_pic();
        }

        public void set_from_url(string url) {
            this.url = url;
            load_pic();
        }
        
        public void set_file_name(string file_name) {
                //this.set_from_file(file_name);
                pixbuf = img_cache.from_cache(file_name);
                
                if(pixbuf.width > pix_size || pixbuf.height > pix_size) {
                        pixbuf = pixbuf.scale_simple(pix_size, pix_size, Gdk.InterpType.BILINEAR);
                }

                set_active(active);

                //pixbuf = pixbuf.add_alpha(false, 0xff, 0xff, 0xff)
                
                redraw();
        }

        public void set_active(bool active) {
            this.active = active;

            if (active)
                cpixbuf = pixbuf;
            else {
                if (ipixbuf == null && pixbuf != null)
                    ipixbuf = pixbuf.composite_color_simple (pixbuf.width, pixbuf.height, Gdk.InterpType.BILINEAR, 50, 24, 0xd9d7d5, 0xd9d7d5);
                cpixbuf = ipixbuf;
            }

            redraw();
        }
        
        public override bool expose_event(Gdk.EventExpose event) {
                Context ctx = Gdk.cairo_create(this.window);
                
                if(cpixbuf != null) {
                        /*
                        if(!pixbuf.has_alpha) {
                                draw_rounded_path(ctx, allocation.x + 2, allocation.y + 2, allocation.width - 2,
                                        allocation.height - 2, 4);
                                ctx.set_source_rgb(242 / 256.0, 242 / 256.0, 242 / 256.0);
                                ctx.fill_preserve();
                                ctx.clip();
                                
                                ctx.reset_clip();
                                
                                draw_rounded_path(ctx, allocation.x + 1, allocation.y + 1, allocation.width - 2,
                                        allocation.height - 2, 4);
                                ctx.set_source_rgb(217 / 256.0, 217 / 256.0, 217 / 256.0);
                                ctx.fill_preserve();
                                ctx.clip();
                                
                                ctx.reset_clip();
                        }
                        */
                        
                        draw_rounded_path(ctx, allocation.x, allocation.y, allocation.width, allocation.height, 4);
                        
                        Gdk.cairo_set_source_pixbuf(ctx, cpixbuf, allocation.x, allocation.y);
                        ctx.clip();
                        ctx.paint();
                }
                return false;
        }
        
        public static void draw_rounded_path(Context ctx, double x, double y,
                double width, double height, double radius) {
                
                double degrees = M_PI / 180.0;
                
                ctx.new_sub_path();
                ctx.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
                ctx.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
                ctx.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
                ctx.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
                ctx.close_path();
        }
        
        private void redraw() {
                if (null == this.window)
                        return;

                unowned Gdk.Region region = this.window.get_clip_region();
                this.window.invalidate_region(region, true);
                this.window.process_updates(true);
    }
    
    public void load_pic() {
                try {
                        thread = Thread.create<void*>(load_pic_thread, true);
                } catch(GLib.Error e) {
                }
        }
        
        private void* load_pic_thread() {
                string? img_path = img_cache.download(url);
                if(img_path != null) {
                        
                        Idle.add(() => {
                                thread.join();
                                thread = null;
                                this.set_file_name(img_path);
                                return false;
                        });
                }
                
                return null;
        }
}
