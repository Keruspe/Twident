using Gtk;
using Cairo;
using TwidentEnums;
using Gee;

public class StreamIcon : EventBox, Redrawable {

	private const double TEXT_W_OFFSET = 6;
		private const double TEXT_H_OFFSET = 3;
		private const double FRESH_W_OFFSET = 4;
		private const double FRESH_H_OFFSET = 10;
		private double MAX_RGB = (double) uint16.MAX;
		private const int RADIUS = 5;
		private const double M_PI = 3.1415926535;
	
	public signal void activated(AStream stream);
	
	public AStream stream;
	
	//private Menu? menu = null;
	
	private Gdk.Pixbuf? status_icon = null;
	
	private Gdk.Pixbuf? icon = null;
	//private Gdk.Pixbuf? icon_inactive = null;
	private Gdk.Pixbuf? icon_hovered = null;
	private Gdk.Pixbuf? icon_pressed = null;
	//private Gdk.Pixbuf? icon_active_hovered = null;
	
	private Gdk.Pixbuf? icon_tmp = null;
	
	private int size = 48;
	
	public State st = State.INACTIVE;
	
	private bool checked {get; set; default = false;}
	
	public enum State {
		ACTIVE,
		ACTIVE_HOVERED,
		INACTIVE,
		HOVERED,
		PRESSED
	}
	
	public StreamIcon(AStream stream, string tooltip, owned Gdk.Pixbuf icon,
		int size = 48) {
		
		this.stream = stream;
		
		set_tooltip_text(tooltip);
		
		if(icon.width > size - 20)
			icon = icon.scale_simple(size - 20, size - 20, Gdk.InterpType.BILINEAR);
		
		this.icon = icon;
		
		this.size = size;
		
		set_size_request(size, size);
		set_has_window(false);
		
		icon_hovered = new Gdk.Pixbuf(Gdk.Colorspace.RGB, icon.has_alpha, icon.bits_per_sample, icon.width, icon.height);
		icon.saturate_and_pixelate(icon_hovered, (float) 1.5, false);
		//icon.composite(icon_hovered, 0, 0, icon.width, icon.height, 0, 0, 1, 1, Gdk.InterpType.NEAREST, 100);
		
		icon_pressed = icon.scale_simple(icon.width - 2, icon.height - 2, Gdk.InterpType.BILINEAR);
		
		set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
		set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);
		set_events(Gdk.EventMask.BUTTON_PRESS_MASK);
		set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
		
		enter_notify_event.connect(on_enter);
		leave_notify_event.connect(on_leave);
		button_press_event.connect(on_press);
		button_release_event.connect(on_release);
		
		this.stream.notify["status"].connect(set_status);
		//this.notify["checked"].connect(set_checked);
		this.stream.notify["fresh-items"].connect(fresh_items_changed);
		
		if(stream.status != StreamStatus.READY) {
			ParamSpec? pspec = null;
			set_status(pspec);
		}
	}
	
	public void set_checked_simple(bool checked) {
		this.checked = checked;
		
		if(checked)
			st = State.ACTIVE;
		else
			st = State.INACTIVE;
		
		redraw();
	}
	
	private void set_status(ParamSpec? pspec) {
		switch(stream.status) {
		case StreamStatus.READY:
			status_icon = null;
			break;
		
		case StreamStatus.UPDATING:
                    try {
			status_icon = new Gdk.Pixbuf.from_file(Config.UPDATING_PATH);
                    } catch (GLib.Error e) {
                    }
			break;
		}
		
		redraw();
	}

	private void fresh_items_changed(ParamSpec? pspec) {
		//debug("=======================%i", stream.fresh_items);
		redraw();
		}
	
	private bool on_enter(Gdk.EventCrossing event) {
		if(checked)
			st = State.ACTIVE_HOVERED;
		else
			st = State.HOVERED;
		
		redraw();
		
		return false;
	}
	
	private bool on_leave(Gdk.EventCrossing event) {
		if(checked)
			st = State.ACTIVE;
		else
			st = State.INACTIVE;
		
		redraw();
		return false;
	}
	
	private bool on_press(Gdk.EventButton event) {
		switch(event.button) {
		case 1:
			st = State.PRESSED;
			redraw();
			activated(stream); //emit signal
			return true;
		case 3:
			context_menu(event);
			return true;
		}
		
		
		//st = State.ACTIVE;
		return true;
	}
	
	private bool on_release(Gdk.EventButton event) {
		return true;
	}
	
	private bool context_menu(Gdk.EventButton event) {
		var menu = new Gtk.Menu();
		
		foreach(MenuItems item in stream.popup_items) {
			MenuItems sitem = item;
			debug("action: %d", sitem);
			ImageMenuItem menu_item = item2menu(sitem);
			
			menu_item.activate.connect(() => {
				stream.account.streams_actions_tracker(stream, sitem);
			});
			menu.append(menu_item);
		}
		
		menu.show_all();
		debug("%d", (int) event.time);
		menu.popup(null, null, null, 1, event.time);
		
		return true;
	}
	
	public static ImageMenuItem item2menu(MenuItems item) {
		string label = "";
		
		switch(item) {
		case MenuItems.SETTINGS:
			label = _("Settings...");
			break;
		
		case MenuItems.REMOVE:
			label = _("Remove");
			break;
		
		case MenuItems.REFRESH:
			label = _("Refresh");
			break;
		
		case MenuItems.MORE:
			label = _("Get more");
			break;
		}
		
		ImageMenuItem menu_item = new ImageMenuItem.with_label(label);
		
		return menu_item;
	}
	
	
	public override bool expose_event(Gdk.EventExpose event) {
		Context ctx = Gdk.cairo_create(this.window);
		
		Allocation alloc;
		get_allocation(out alloc);
		
		/*
		Gdk.Color color = {1, 240, 119, 70};
		Gdk.cairo_rectangle(ctx, {alloc.x, alloc.y, alloc.width, alloc.height});
		
		Cairo.Pattern grad = new Cairo.Pattern.linear(alloc.x, alloc.y, alloc.x, alloc.height);
		grad.add_color_stop_rgba(0, color.red/256.0, color.green/256.0, color.blue/256.0, 1.0);
		grad.add_color_stop_rgba(0.5, color.red/256.0, color.green/256.0, color.blue/256.0, 0.5);
		grad.add_color_stop_rgba(1, color.red/256.0, color.green/256.0, color.blue/256.0, 1.0);
		
		ctx.set_source(grad);
		
		ctx.fill();
		*/
		base.expose_event(event);
		
		switch(st) {
		case State.INACTIVE:
			icon_tmp = icon;//_inactive;
			break;
		case State.ACTIVE:
			Gdk.Color color = {1, 242, 241, 240};
			draw_rect(ctx, alloc, color);
			icon_tmp = icon;
			break;
		case State.ACTIVE_HOVERED:
			Gdk.Color color = {1, 254, 253, 252};
			draw_rect(ctx, alloc, color);
			icon_tmp = icon_hovered;//icon_active_hovered;
			break;
		case State.HOVERED:
			//Gdk.Color color = {1, 229, 226, 224};
			//draw_rect(ctx, alloc, color);
			icon_tmp = icon_hovered;
			break;
		case State.PRESSED:
			Gdk.Color color = {1, 229, 226, 224};
			draw_rect(ctx, alloc, color);
			icon_tmp = icon_pressed;
			break;
		}
		
		if(icon_tmp != null) {
			Gdk.Rectangle big_rect = {alloc.x + (alloc.width - icon.width) / 2,
				alloc.y + (alloc.height - icon.height) / 2 , icon.width, icon.height};
			Gdk.cairo_rectangle(ctx, big_rect);
			Gdk.cairo_set_source_pixbuf(ctx, icon_tmp, big_rect.x,
				big_rect.y);
			
			ctx.fill();
			
			
			if(status_icon != null) {
				Gdk.Rectangle status_rect = {big_rect.x + big_rect.width - status_icon.width,
					big_rect.y + big_rect.height - status_icon.height, status_icon.width,
					status_icon.height};
				
				Gdk.cairo_rectangle(ctx, status_rect);
				Gdk.cairo_set_source_pixbuf(ctx, status_icon, status_rect.x,
					status_rect.y);
				
				ctx.fill();
			}
		}
		//draw fresh items
		if(stream.fresh_items > 0) {
		Pango.FontDescription font_desc = style.font_desc;
		string fresh_string = stream.fresh_items.to_string();
		
		Gdk.Color fg_color = style.fg[Gtk.StateType.SELECTED];
		Gdk.Color bg_color = style.bg[Gtk.StateType.SELECTED];
		Gdk.Color border_color = make_darker(bg_color, 20);
		
		ctx.select_font_face(font_desc.get_family(), FontSlant.NORMAL, FontWeight.BOLD);
		ctx.set_font_size(font_desc.get_size() / 1000);
		
		//text margins
		TextExtents ex_up;
		ctx.text_extents(fresh_string, out ex_up);
		
		//int area_width = (int) (ex_up.width + TEXT_W_OFFSET * 2);
		
		//draw rect
		double height = ex_up.height + TEXT_H_OFFSET * 2;
		double rect_w = ex_up.width + TEXT_W_OFFSET * 2;
		ctx.set_line_width(0.5);
		draw_rounded_rect(ctx, bg_color, alloc.x + alloc.width - rect_w - FRESH_W_OFFSET,
		alloc.y + (alloc.height - height) / 2.0 - FRESH_H_OFFSET,
		rect_w, height, RADIUS, border_color);
		
		//draw text
		ctx.set_source_rgb(fg_color.red / MAX_RGB, fg_color.green / MAX_RGB,
		fg_color.blue / MAX_RGB);
		
		ctx.move_to(alloc.x - TEXT_W_OFFSET + alloc.width - ex_up.width - FRESH_W_OFFSET,
		alloc.y + (alloc.height + ex_up.height) / 2.0 - FRESH_H_OFFSET);
		ctx.show_text(fresh_string);
		}
		return false;
	}

	private void draw_rounded_rect(Context ctx, Gdk.Color bg_color, double x,
		double y, double width, double height, double radius,
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
		
		if(border_color != null) {
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
				public static Gdk.Color make_darker(Gdk.Color color, int percent) {
		if(percent > 99)
		percent = 99;
		
		Gdk.Color new_color = color;
		
		new_color.red = color.red - (color.red / 100) * percent;
		new_color.green = color.green - (color.green / 100) * percent;
		new_color.blue = color.blue - (color.blue / 100) * percent;
		
		if(new_color.red < 0)
		new_color.red = 0;
		if(new_color.green < 0)
		new_color.green = 0;
		if(new_color.blue < 0)
		new_color.blue = 0;
		
		return new_color;
		}
	
	private void draw_rect(Context ctx, Allocation alloc, Gdk.Color color) {
		Gdk.cairo_rectangle(ctx, {alloc.x, alloc.y, alloc.width, alloc.height});
		
		Cairo.Pattern grad = new Cairo.Pattern.linear(alloc.x, alloc.y, alloc.x, alloc.height);
		grad.add_color_stop_rgba(0, color.red/256.0, color.green/256.0, color.blue/256.0, 1.0);
		grad.add_color_stop_rgba(0.5, color.red/256.0, color.green/256.0, color.blue/256.0, 0.5);
		grad.add_color_stop_rgba(1, color.red/256.0, color.green/256.0, color.blue/256.0, 1.0);
		
		ctx.set_source(grad);
		
		ctx.fill();
		
		//draw top and bottom lines
		Gdk.cairo_rectangle(ctx, {alloc.x, alloc.y, alloc.x + alloc.width, 1});
		ctx.set_source_rgb(178/256.0, 176/256.0, 164/256.0);
		ctx.fill_preserve();
		
		Gdk.cairo_rectangle(ctx, {alloc.x, alloc.y + alloc.height, alloc.x + alloc.width, 1});
		ctx.set_source_rgb(178/256.0, 176/256.0, 164/256.0);
		ctx.fill_preserve();
	}
}

public class StreamsWidget : VBox {
	
	public signal void activated(AStream stream);
	
	private AAccount account;
	
	//public AStream? current_stream = null;
	
	public StreamsWidget(AAccount account) {
		GLib.Object(homogeneous: false, spacing: 0);
		
		this.account = account;
		
		//setup streams
		foreach(AStream stream in account.streams) {
			new_stream_icon(stream);
		}
		
		account.streams.cursor_changed.connect(move_cursor);
		account.streams.removed.connect(stream_removed);
		account.streams.added.connect(stream_added);
		
		show_all();
	}
	
	private void new_stream_icon(AStream stream) {
		StreamIcon icon = create_icon(stream);
		icon.activated.connect(on_activated);
		icon.show_all();
		pack_start(icon, false, false, 0);
	}
	
	private void move_cursor(AStream? new_stream, AStream? old_stream) {
		StreamIcon? icon = stream_icon_from_stream(new_stream);
		if(icon != null)
			icon.set_checked_simple(true);
		
		icon = stream_icon_from_stream(old_stream);
		if(icon != null)
			icon.set_checked_simple(false);
	}
	
	private void stream_removed(AStream stream) {
		StreamIcon? icon = stream_icon_from_stream(stream);
		
		if(icon != null) {
			remove(icon);
			icon.dispose();
		}
		
		debug("removed");
	}
	
	private void stream_added(AStream stream) {
		new_stream_icon(stream);
	}
	
	public void on_activated(AStream stream) {
		if(stream == account.streams.get_current())
			return;
		
		account.streams.set_current(stream);
		/*
		if(current_stream != null) {
			StreamIcon? icon = stream_icon_from_stream(current_stream);
			debug("ok");
			if(icon != null) {
				icon.set_checked_simple(false);
				debug("ok");
			}
		}
		
		current_stream = stream;
		activated(stream);	
		*/
	}
	
	private StreamIcon? stream_icon_from_stream(AStream? stream) {
		if(stream == null)
			return null;
		
		foreach(Widget i in this.get_children()) {
			if(i.get_type() != typeof(StreamIcon))
				continue;
			
			if(((StreamIcon) i).stream == stream) {
					return (StreamIcon) i;
			}
		}
		
		return null;
	}
	
	private StreamIcon create_icon(AStream stream) {
		Gdk.Pixbuf pic = streams_types[stream.stream_type].icon;
		string tooltip = streams_types[stream.stream_type].name;
		StreamIcon icon = new StreamIcon(stream, tooltip, pic);
		//icon.show();
		return icon;
	}
}

public class AccountWidget : EventBox, Redrawable {
	
	public AAccount account;
	private Accounts accounts;
	private Avatar avatar;
	
	public bool active {get; set; default = false;}
	
	public signal void account_activate(AccountWidget acc_widget);
	
	public class AccountWidget(AAccount account, Accounts accounts) {
		this.account = account;
		this.accounts = accounts;
		
		set_size_request(48, 48);
		
		avatar = new Avatar.from_url(this.account.s_avatar_url, 48);
		avatar.show();
		
		add(avatar);
		
		notify["active"].connect(on_active);
		
		set_events(Gdk.EventMask.BUTTON_PRESS_MASK);
		button_press_event.connect(on_press);
		
		set_has_window(false);
	}
	
	private bool on_press(Gdk.EventButton event) {
		switch(event.button) {
		case 1:
			if(active)
				return true;
			
			active = true;
			account_activate(this); //emit signal
			break;
		case 3:
			context_menu(event);
			break;
		}
		
		return true;
	}
	/*
	private bool on_release(Gdk.EventButton event) {
		
		
		return true;
	}*/
	
	public void on_active(ParamSpec? pspec = null) {
		avatar.set_active(active);
		redraw();
	}
	
    
    private bool context_menu(Gdk.EventButton event) {
		var menu = new Gtk.Menu();
		
		var streams_menu = new Gtk.Menu(); //for streams
		
		foreach(StreamEnum stream in account.avaliable_streams().keys) {
			string label = streams_types.get(stream).name;
			ImageMenuItem menu_item = new ImageMenuItem.with_label(label);
                        menu_item.set_always_show_image(true);
			Image img = streams_types.get(stream).get_menu_image();
			
			if(img != null)
				menu_item.set_image(img);
			
			menu_item.activate.connect(() => { //add new stream to account
				account.add_stream(stream, true);
			});
			streams_menu.append(menu_item);
		}
		
		var streams_item = new Gtk.MenuItem.with_label("Add stream");
		streams_item.set_submenu(streams_menu);
		menu.append(streams_item);
		
		foreach(MenuItems item in account.popup_items) {
			MenuItems aitem = item;
			Gtk.MenuItem? menu_item = StreamIcon.item2menu(item); //static method
			
			menu_item.activate.connect(() => {
				accounts.actions_tracker(account, aitem);
			});
			
			if(menu_item != null)
				menu.append(menu_item);
			else
				debug("item doesn't supported");
		}
		
		menu.show_all();
		menu.popup(null, null, null, 1, event.time);
		
		return true;
	}
	
	/*
	public override bool expose_event(Gdk.EventExpose event) {
		base.expose_event(event);
		
		Context ctx = Gdk.cairo_create(this.window);
		
		Allocation alloc;
		get_allocation(out alloc);
		
		if(!active) {
			Avatar.draw_rounded_path(ctx, 0, 0, alloc.width,
				alloc.height, 4);
			ctx.set_source_rgba(242 / 256.0, 241 / 256.0, 240 / 256.0, 0.6);
			ctx.fill_preserve();
		}
		
		return true;
	}*/
}

public class StreamsModel : ArrayList<AStream> {
	
	private AStream? current_stream {get; set; default = null;}
	
	public signal void added(AStream stream);
	public signal void removed(AStream stream);
	public signal void cursor_changed(AStream? new_stream, AStream? old_stream);
	
	public StreamsModel() {
		base();
	}
	
	public override bool add(AStream stream) {
		base.add(stream);
		
		added(stream);
		
		set_current(stream);
		
		return true;
	}
	
	public override bool remove(AStream stream) {
		removed(stream);
		
		base.remove(stream);
		
		if(current_stream == stream) {
			if(this.size < 1)
				set_current(null);
			else {
				this.set_current(this.get(0));
			}
		}
		
		return true;
	}
	
	public void set_current(AStream? stream) {
		if(stream == current_stream)
			return;
		
		if(contains(stream)) {
			cursor_changed(stream, current_stream); //emit signal
			current_stream = stream;
		}
		else
			debug("no such stream");
	}
	
	public AStream? get_current() {
		if(current_stream == null) {
			if(this.size == 0)
				return null;
			
			this.set_current(this.get(0));
		}
		
		return current_stream;
	}
}

public class AccountsWidget : EventBox {
	
	public signal void cursor_moved(AAccount account, AStream? stream);
	
	private Accounts accounts;
	
	//private AAccount? current_account = null;
	
	private VBox main_vb;
	private VBox top_acc;
	private HBox top_acc_h;
	private VBox streams_box;
	private VBox bottom_acc;
	private HBox bottom_acc_h;
	
	private HashMap<AAccount, StreamsWidget> accounts_map {get; set; default = new HashMap<AAccount, StreamsWidget>();}
	
	public AccountsWidget(Accounts accounts) {
		this.accounts = accounts;
		
		set_size_request(56, 100);
		set_has_window(false);
		
		main_vb = new VBox(false, 4);
		top_acc = new VBox(false, 2);
		top_acc_h = new HBox(false, 2);
		streams_box = new VBox(false, 0);
		bottom_acc_h = new HBox(false, 2);
		bottom_acc = new VBox(false, 2);
		
		top_acc.pack_start(top_acc_h, false, false, 4);
		bottom_acc_h.pack_start(bottom_acc, false, false, 4);
		
		main_vb.pack_start(top_acc, false, false, 2);
		main_vb.pack_start(streams_box, false, false, 0);
		main_vb.pack_end(bottom_acc_h, false, false, 0);
		/*
		if(accounts.size > 0) {
			current_account = accounts.get(0);
			AccountWidget aw = new AccountWidget(current_account);
			aw.account_activate.connect(on_account_activate);
			top_acc.pack_start(aw, false, false, 0);
			aw.show();
			aw.active = true;
			
			StreamsWidget sw = setup_streams(accounts.get(0));
			accounts_map.set(accounts.get(0), sw);
			streams_box.pack_start(sw, false, false, 0);
		}*/
		
		if(accounts.size - 1 < settings.current_account)
			settings.current_account = 0;
		
		//accounts setup
		foreach(AAccount account in accounts) {
			//if(account == current_account)
			//	continue;
			/*
			AccountWidget aw = new AccountWidget(account, accounts);
			aw.account_activate.connect(on_account_activate);
			
			StreamsWidget sw = setup_streams(account);
			accounts_map.set(account, sw);
			
			if(accounts.index_of(account) == settings.current_account) {
				current_account = account;
				top_acc_h.pack_start(aw, false, false, 4);
				aw.active = true;
				
				streams_box.pack_start(sw, false, false, 0);
			} else {
				bottom_acc.pack_start(aw, false, false, 4);
				aw.active = false;
			}
			
			aw.show();*/
			add_account(account);
		}
		
		add(main_vb);
		
		accounts.account_was_removed.connect(remove_account);
		accounts.insert_new_account.connect(add_account);
		accounts.current_changed.connect(current_changed);
		}
		
		private void add_account(AAccount account) {
		AccountWidget aw = new AccountWidget(account, accounts);
		//aw.account_activate.connect(on_account_activate);
		aw.account_activate.connect(account_activate);
		
		StreamsWidget sw = setup_streams(account);
		accounts_map.set(account, sw);
				if(account == accounts.current) {
		//current_account = account;
		top_acc_h.pack_start(aw, false, false, 2);
		aw.active = true;
		
		streams_box.pack_start(sw, false, false, 0);
		} else {
		bottom_acc.pack_start(aw, false, false, 2);
		aw.active = false;
		}
		
		aw.show();
	}
	
	private void remove_account(AAccount account) {
		AccountWidget rw = widget_from_account(account);
		StreamsWidget sw = accounts_map.get(account);
		
		if(accounts.current == account) {
			top_acc_h.remove(rw);
			streams_box.remove(sw);
			
			accounts.current = null;
			
			if(bottom_acc.get_children().length() > 0) {
				((AccountWidget) bottom_acc.get_children().nth_data(0)).on_active();
			}
			//current_account = null;
		} else {
			bottom_acc.remove(rw);
		}
	}
	
	private StreamsWidget setup_streams(AAccount account) {
		StreamsWidget stream_widget = new StreamsWidget(account);
		stream_widget.activated.connect(stream_activate);
		
		return stream_widget;
	}
	
	public void setup_current_stream() {
		if(accounts.current == null)
			return;
		
		if(accounts.current.streams.size < 1)
			return;
		
		accounts.current.streams.set_current(accounts.current.streams.get(0));
	}

	private void account_activate(AccountWidget acc_widget) {
		accounts.current = acc_widget.account;
		}
		
		private void current_changed(AAccount? new_account, AAccount? old_account) {
		if(old_account == null)
	return;
		
		AccountWidget? old_widget = widget_from_account(old_account);
		if(old_widget != null) {
		top_acc_h.remove(old_widget);
		old_widget.active = false;
		bottom_acc.pack_start(old_widget, false, false, 4);
		
		if(streams_box.get_children().length() == 1) {
		streams_box.remove(streams_box.get_children().nth_data(0));
		}
		}
		
		if(new_account == null)
		return;
		
		AccountWidget? new_widget = widget_from_account(new_account);
		if(new_widget != null) {
		bottom_acc.remove(new_widget);
		top_acc_h.pack_start(new_widget, false, false, 4);
		
		new_widget.active = true;
		streams_box.pack_start(accounts_map.get(new_account), false, false, 0);
		}
		
		AStream? old_stream = old_account.streams.get_current();
		AStream? stream = new_account.streams.get_current();
		
		if(stream == null)
		return;
		
		new_account.streams.cursor_changed(stream, old_stream);
	}
	
	/*private void on_account_activate(AccountWidget acc_widget) {
		AccountWidget? tmp_widget = widget_from_account(accounts.current);
		if(tmp_widget != null) {
			top_acc_h.remove(tmp_widget);
			tmp_widget.active = false;
			bottom_acc.pack_start(tmp_widget, false, false, 0);
			
			if(streams_box.get_children().length() == 1) {
				streams_box.remove(streams_box.get_children().nth_data(0));
			}
		}
		
		bottom_acc.remove(acc_widget);
		top_acc_h.pack_start(acc_widget, false, false, 4);
		
		AStream? old_stream = accounts.current.streams.get_current(); //get old active stream
		
		accounts.current = acc_widget.account;
		
		if(accounts.current != null)
			settings.current_account = accounts.index_of(accounts.current); //write to settings
		
		streams_box.pack_start(accounts_map.get(accounts.current), false, false, 0);
		
		AStream? stream = accounts.current.streams.get_current();
		
		if(stream == null)
			return;
		
		accounts.current.streams.cursor_changed(stream, old_stream);
	}*/
	
	private AccountWidget? widget_from_account(AAccount account) {
		foreach(Widget aw in top_acc_h.get_children()) {
			if(((AccountWidget) aw).account == account)
				return (AccountWidget) aw;
		}
		
		foreach(Widget aw in bottom_acc.get_children()) {
			if(((AccountWidget) aw).account == account)
				return (AccountWidget) aw;
		}
		
		return null;
	}
	
	private void stream_activate(AStream stream) {
		//cursor_moved(stream.account, stream); //emit signal
	}
	
	public override bool expose_event(Gdk.EventExpose event) {
		Context ctx = Gdk.cairo_create(this.window);
		
		Allocation alloc;
		get_allocation(out alloc);
		//Gdk.Color color = {1, 230, 224, 218};
		Gdk.cairo_rectangle(ctx, {alloc.x, alloc.y, alloc.width, alloc.height});
		/*
		Cairo.Pattern grad = new Cairo.Pattern.linear(0, 1, alloc.width, 1);
		grad.add_color_stop_rgb(0, color.red/256.0, color.green/256.0, color.blue/256.0);
		grad.add_color_stop_rgb(0.5, 212/256.0, 211/256.0, 210/256.0);
		grad.add_color_stop_rgb(1, color.red/256.0, color.green/256.0, color.blue/256.0);
		
		ctx.set_source(grad);*/
		ctx.set_source_rgb(230/256.0, 224/256.0, 218/256.0);
		ctx.fill();
		
		base.expose_event(event);
		
		Gdk.cairo_rectangle(ctx, {alloc.width - 1, alloc.y, 1, alloc.height});
		ctx.set_source_rgb(178/256.0, 176/256.0, 164/256.0);
		ctx.fill_preserve();
		
		Gdk.cairo_rectangle(ctx, {alloc.width - 2, alloc.y, 1, alloc.height});
		ctx.set_source_rgba(178/256.0, 176/256.0, 164/256.0, 0.4);
		ctx.fill_preserve();
		
		Gdk.cairo_rectangle(ctx, {alloc.width - 3, alloc.y, 1, alloc.height});
		ctx.set_source_rgba(178/256.0, 176/256.0, 164/256.0, 0.2);
		ctx.fill_preserve();
		
		return true;
	}
}
