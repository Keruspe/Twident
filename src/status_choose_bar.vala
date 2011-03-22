using Gtk;

public class StatusChooseBar : Toolbar {
	
	private Accounts accounts;
	private ToolButton open_img;
	private Label count;
	
	public StatusChooseBar(Accounts accounts) {
		this.accounts = accounts;
		
		open_img = new ToolButton(null, _("Upload image"));
		open_img.set_icon_name("gtk-open");
		this.add(open_img);
		
		SeparatorToolItem separator1 = new SeparatorToolItem();
		separator1.set_draw(false);
		this.add(separator1);
		
		count = new Label("");
		count.modify_font(Pango.FontDescription.from_string("sans 18"));
		ToolItem to = new ToolItem();
		to.add(count);
		add(to);
		
		SeparatorToolItem separator2 = new SeparatorToolItem();
		separator2.set_draw(false);
		separator2.set_expand(true);
		this.add(separator2);
		
		generate_acc();
		
		set_icon_size(IconSize.SMALL_TOOLBAR);
		toolbar_style = ToolbarStyle.ICONS;
		
		accounts.insert_new_account.connect((acc) => {
			add_new_account(acc);
			update_config();
		});
		
		accounts.element_was_removed.connect((path, acc) => {
			if(path.contains(":")) //just stream, not account
			return;
		
			foreach(Widget tb in this.get_children()) {
				if(tb.get_type() != typeof(ToggleToolButton))
					continue;
				
				if(((ToggleToolButton) tb).label == acc.get_hash()) {
					this.remove(tb);
				}
			}
			
			update_config();
		});
	}
	
	public void set_count(int chars) {
		count.set_markup("<b>%d</b>".printf(chars));
	}
	
	public void select(AAccount account) {
		foreach(Widget tb in this.get_children()) {
			if(tb.get_type() != typeof(ToggleToolButton))
				continue;
			
			if(((ToggleToolButton) tb).label == account.get_hash()) {
				((ToggleToolButton) tb).set_active(true);
			}
		}
		
		update_config();
	}
	
	public void unselect_all() {
		settings.selected_for_posting.clear();
				
		foreach(Widget tb in this.get_children()) {
			if(tb.get_type() != typeof(ToggleToolButton))
				continue;
			
			if(((ToggleToolButton) tb).active) {
				((ToggleToolButton) tb).set_active(false);
			}
		}
	}
	
	private void update_config() {
		settings.selected_for_posting.clear();
				
		foreach(Widget tb in this.get_children()) {
			if(tb.get_type() != typeof(ToggleToolButton))
				continue;
			
			if(((ToggleToolButton) tb).active) {
				settings.selected_for_posting.add(((ToolButton) tb).label);
			}
		}
	}
	
	private void add_new_account(AAccount account) {
		ToggleToolButton tb = new ToggleToolButton();
		tb.label = account.get_hash();
		tb.set_tooltip_text("%s (%s)".printf(account.s_name, account.id));
		
		if(settings.selected_for_posting.contains(tb.label))
			tb.set_active(true);
		
		account.notify["userpic"].connect((s) => {
			Image img = new Image.from_pixbuf(account.userpic.scale_simple(
				24, 24, Gdk.InterpType.HYPER));
			img.show();
			tb.set_icon_widget(img);
		});
		
		tb.toggled.connect(() => {
			update_config();
		});
		
		/*
		if(account.userpic != null) {
			Image img = new Image.from_pixbuf(account.userpic);
			img.pixel_size = 48;
			tb.set_icon_widget(img);
		}*/
		this.add(tb);
		tb.show();
	}
	
	private void generate_acc() {
		foreach(AAccount account in this.accounts) {
			add_new_account(account);
		}
	}
}
