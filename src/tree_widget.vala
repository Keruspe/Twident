using Gtk;
using TwidentEnums;

public class TreeWidget : TreeView {
	
	public signal void cursor_moved(AStream stream);
	
	private Window parent_win;
	private Accounts accounts;

	private TreeStore store;
	public TreePath current_tree_path;

	private Gdk.Pixbuf pix_updating;
	
	public Frame frame;
	
	public TreeWidget(Window parent_win, Accounts accounts) {
		this.parent_win = parent_win;
		this.accounts = accounts;

		try {
			pix_updating = new Gdk.Pixbuf.from_file(Config.UPDATING_PATH);
		} catch (GLib.Error e) {
			stderr.printf("%s\n", e.message);
		}
		
		accounts.insert_new_account.connect(new_account);
		accounts.insert_new_stream_after.connect((after_path, stream) => {
			new_stream(after_path, stream, true);
		});
		accounts.element_was_removed.connect(remove_element);
		
		set_rules_hint(false);
		set_headers_visible(false);
		
		frame = new Frame(null);
		frame.add(this);
		
		setup();
		
		accounts.fresh_items_changed.connect((items, path) => {
			TreeIter iter;
			
			store.get_iter_from_string(out iter, path);
			store.set(iter, 2, items.to_string(), -1);
		});
		
		accounts.account_was_changed.connect((path, account) => {
			TreeIter iter;
			store.get_iter_from_string(out iter, path);
			new_account_general(iter, account);
		});
		
		accounts.stream_was_changed.connect((path, stream) => {
			TreeIter iter;
			store.get_iter_from_string(out iter, path);
			
			new_stream_general(iter, stream);
		});
		
		button_release_event.connect(context_menu);
	}

	/** Building tree of accounts */
	public void setup() {
		//var icon_cell = new CellRendererPixbuf();
		//icon_cell.stock_size = 24;
		
		insert_column_with_attributes(-1, "Icon", new IconWithStatusCellRrenderer(), "meta_row", 0, null);
		//insert_column_with_attributes(-1, "Name", new CellRendererText(), "text", 1, null);
		//insert_column_with_attributes(-1, "New messages", new UpdatesCellRrenderer(), "text", 2, null);
	
		store = new TreeStore(1, typeof(MetaRow));
		set_model(store);

		foreach(AAccount acc in accounts) {
			TreeIter iter;
			store.append(out iter, null);
			new_account_general(iter, acc);
			new_streams(acc, iter);
		}

		expand_all();

		cursor_changed.connect(cursor_changed_callback);
	}
	
	/** Set current item */
	public void set_current(string path) {
		if(path == "")
			return;
		
		TreePath tree_path = new TreePath.from_string(path);
		set_cursor(tree_path, null, false);
	}
	
	/** When current stream or account is changed */
	private void cursor_changed_callback() {
		TreePath? path;
		TreeViewColumn column;

		get_cursor(out path, out column);
		
		if(path == null || path.to_string() == current_tree_path.to_string())
			return;
		
		current_tree_path = path;
		

		if(path.get_depth() == 2) { //stream
			int account_index = int.parse(path.to_string().split(":")[0]);
			int stream_index = int.parse(path.to_string().split(":")[1]);
			
			AAccount active_account = accounts.get(account_index);
			AStream active_stream = active_account.streams.get(stream_index);

			cursor_moved(active_stream);
		}
	}

	/** Get current account */
	private AAccount? get_current_account() {
		TreePath path;
		TreeViewColumn column;

		get_cursor(out path, out column);
		string spath = path.to_string().split(":")[0];
		
		return accounts.get(int.parse(spath));
	}

	/** Get current stream index */
	private int? get_stream_index() {
		TreePath path;
		TreeViewColumn column;

		get_cursor(out path, out column);
		if(path.get_depth() < 2)
			return null;
		
		string spath = path.to_string().split(":")[1];
		
		return int.parse(spath);
	}
	
	/** Context menu for accounts and streams */
	private bool context_menu(Gdk.EventButton event) {
		if(event.button != 3)
			return false;
		
		AAccount? account = get_current_account();
		if(account == null)
			return false;
		
		int? stream_index = get_stream_index();
		
		if(stream_index == null) { //display account menu
			Menu menu = new Menu(); //main popup

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
				MenuItem? menu_item = item2menu(item);
				
				menu_item.activate.connect(() => {
					accounts.actions_tracker(account, aitem, parent_win);
				});
				
				if(menu_item != null)
					menu.append(menu_item);
			}
			
			menu.show_all();
			menu.popup(null, null, null, 1, event.time);
		} else { //display stream menu
			Menu menu = new Menu();
			
			foreach(MenuItems item in account.streams.get(stream_index).popup_items) {
				MenuItems sitem = item;
				ImageMenuItem menu_item = item2menu(sitem);
				
				menu_item.activate.connect(() => {
					account.streams_actions_tracker(stream_index, sitem);
				});
				menu.append(menu_item);
			}
			
			menu.show_all();
			menu.popup(null, null, null, 1, event.time);
		}
		return true;
	}
	
	private ImageMenuItem item2menu(MenuItems item) {
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
	
	/** add new account to the tree */
	private void new_account(AAccount account) {
		TreeIter iter;
		store.append(out iter, null);
		
		new_account_general(iter, account);
		new_streams(account, iter);
	}
	
	private void new_account_general(TreeIter iter, AAccount account) {
		Gdk.Pixbuf? acc_icon = account.userpic;
		
		MetaRow meta_icon = new MetaRow(acc_icon,
			accounts_types.get(account.get_type()).icon,
			"%s (%s)".printf(account.s_name, accounts_types.get(account.get_type()).name),
			true);
		store.set(iter, 0, meta_icon);
	}
	
	private void new_streams(AAccount account, TreeIter iter) {
		foreach(AStream stream in account.streams) {
			TreeIter iter_in;
			store.append(out iter_in, iter);
			
			new_stream_general(iter_in, stream);
		}
	}
	
	/** add new stream to the tree */
	private void new_stream(string after_path, AStream stream, bool activate = false) {
		TreeIter after_iter;
		store.get_iter_from_string(out after_iter, after_path);

		TreeIter iter;
		store.append(out iter, after_iter);

		new_stream_general(iter, stream);
		
		if(activate) {
			TreePath needed_path = store.get_path(iter);
			set_cursor(needed_path, null, false);
		}
	}
	
	/** Remove stream or account */
	private void remove_element(string path, AAccount account, AStream? stream = null) {
		TreeIter iter;
		store.get_iter_from_string(out iter, path);
	}
	
	private void new_stream_general(TreeIter iter, AStream stream) {
		Gdk.Pixbuf stream_icon = streams_types.get(stream.stream_type).get_tree_pixbuf();
		Gdk.Pixbuf? status_icon = null;
		
		switch(stream.status) {
		case StreamStatus.UPDATING:
			status_icon = pix_updating;
			break;
		}
		
		string stream_name;
		
		switch(stream.stream_type) {
		case StreamEnum.SEARCH:
			stream_name = ((ISearch) stream).s_keyword;
			break;
		case StreamEnum.GROUP:
			stream_name = "!" + ((Identica.StreamGroup) stream).s_group_name;
			break;
		default:
			stream_name = streams_types.get(stream.stream_type).name;
			break;
		}
		
		//MetaIcon meta_icon = new MetaIcon(stream_icon);
		store.set(iter, 0, new MetaRow(stream_icon, status_icon, stream_name,
			false, stream.fresh_items));
	}
}
