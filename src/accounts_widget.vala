using Gtk;
using Cairo;
using TwidentEnums;
using Gee;

public class StreamIcon : EventBox {
	
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
	
	public static enum State {
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
		Menu menu = new Menu();
		
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
	
	private void redraw() {
		if (null == this.window)
			return;

		unowned Gdk.Region region = this.window.get_clip_region ();
		this.window.invalidate_region (region, true);
		this.window.process_updates (true);
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
		
		return false;
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

public class AccountWidget : EventBox {
	
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
	
	private void redraw() {
		if (null == this.window)
			return;

		unowned Gdk.Region region = this.window.get_clip_region();
		this.window.invalidate_region(region, true);
		this.window.process_updates(true);
    }
    
    private bool context_menu(Gdk.EventButton event) {
		Menu menu = new Menu();
		
		Menu streams_menu = new Menu(); //for streams
		
		foreach(StreamEnum stream in account.avaliable_streams().keys) {
			string label = streams_types.get(stream).name;
			ImageMenuItem menu_item = new ImageMenuItem.with_label(label);
			Image img = streams_types.get(stream).get_menu_image();
			
			if(img != null)
				menu_item.set_image(img);
			
			menu_item.activate.connect(() => { //add new stream to account
				account.add_stream(stream, true);
			});
			streams_menu.append(menu_item);
		}
		
		MenuItem streams_item = new MenuItem.with_label("Add stream");
		streams_item.set_submenu(streams_menu);
		menu.append(streams_item);
		
		foreach(MenuItems item in account.popup_items) {
			MenuItems aitem = item;
			MenuItem? menu_item = StreamIcon.item2menu(item); //static method
			
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
	
	private AAccount? current_account = null;
	
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
			
			aw.show();
		}
		
		add(main_vb);
		
		accounts.account_was_removed.connect(remove_account);
	}
	
	private void remove_account(AAccount account) {
		AccountWidget rw = widget_from_account(account);
		StreamsWidget sw = accounts_map.get(account);
		
		if(current_account == account) {
			top_acc_h.remove(rw);
			streams_box.remove(sw);
			
			current_account = null;
			
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
		if(current_account == null)
			return;
		
		if(current_account.streams.size < 1)
			return;
		
		current_account.streams.set_current(current_account.streams.get(0));
	}
	
	private void on_account_activate(AccountWidget acc_widget) {
		AccountWidget? tmp_widget = widget_from_account(current_account);
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
		
		AStream? old_stream = current_account.streams.get_current(); //get old active stream
		
		current_account = acc_widget.account;
		
		if(current_account != null)
			settings.current_account = accounts.index_of(current_account); //write to settings
		
		streams_box.pack_start(accounts_map.get(current_account), false, false, 0);
		
		AStream? stream = current_account.streams.get_current();
		
		if(stream == null)
			return;
		
		current_account.streams.cursor_changed(stream, old_stream);
	}
	
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
