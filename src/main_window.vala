using Gtk;
using Gee;

public class MainWindow : Window {
        
        private Accounts accounts;

        //GUI
        private Widget menubar;
        //private TreeWidget tree;
        AccountsWidget acc_widget;
        //private ContentView content_view;
        private ViewArea view_area;
        private StatusBox status_box;
        //private VisualStyle visual_style;
        private VPaned vpaned;
        //private HPaned hpaned;
        
        public MainWindow() {
                set_size_request(380, 600);
                accounts = new Accounts();
                
                //tree = new TreeWidget(this, accounts);
                
                menu_setup();
                
                var vbox = new VBox(false, 0);
                //vbox.pack_start(tree.frame, true, true, 0);
                
                var treebox = new HBox(false, 0);
                treebox.pack_start(vbox, true, true, 0);
                
                visual_style = new VisualStyle(this);
                
                //content_view = new ContentView(accounts, visual_style);
                view_area = new ViewArea(accounts);
                
                HBox webbox = new HBox(false, 0);
                //webbox.pack_start(content_view.frame, true, true, 0);
                webbox.pack_start(view_area, true, true, 0);
                
                status_box = new StatusBox(this, accounts);
                
                HBox statbox = new HBox(false, 0);
                statbox.pack_start(status_box.vbox, true, true, 0);
                
                vpaned = new VPaned();
                vpaned.add1(webbox);
                vpaned.add2(statbox);
                vpaned.set_position(settings.vpaned_position);
                vpaned.notify["position"].connect((s) => {
                        settings.vpaned_position = vpaned.get_position();
                });
                /*
                hpaned = new HPaned();
                hpaned.add1(treebox);
                hpaned.add2(vpaned);
                hpaned.set_position(settings.hpaned_position);
                hpaned.notify["position"].connect((s) => {
                        settings.hpaned_position = hpaned.get_position();
                });
                */

                acc_widget = new AccountsWidget(accounts);

                HBox hb_main = new HBox(false, 0);
                hb_main.pack_start(acc_widget, false, false, 0);
                hb_main.pack_start(vpaned, true, true, 0);
                
                VBox main_box = new VBox(false, 0);
                main_box.pack_start(menubar, false, false, 0);
                main_box.pack_start(hb_main, true, true, 0);
                
                add(main_box);
                show_all();
                
                //hide some widgets
                view_area.generate_views();
                
                signals_setup();
                
                //tree.set_current(settings.current_item);
                acc_widget.setup_current_stream();
        }
        
        private void menu_setup() {
                Gtk.ActionGroup act_group = new Gtk.ActionGroup("main");
                
                Gtk.Action file_menu = new Gtk.Action("FileMenu", "Twident", null, null);
                Gtk.Action edit_menu = new Gtk.Action("EditMenu", "Edit", null, null);
                Gtk.Action view_menu = new Gtk.Action("ViewMenu", "View", null, null);
                Gtk.Action help_menu = new Gtk.Action("HelpMenu", "Help", null, null);
                
                Gtk.Action create_account_act = new Gtk.Action("CreateAccount", _("Add account"),
                        _("Add account"), null);
                
                //setup all account types
                string accounts_string = "";
                foreach(Type t in accounts_types.keys) {
                        Gtk.Action acc_act = new Gtk.Action(t.name(), accounts_types.get(t).name,
                                accounts_types.get(t).description, null);
                        
                        try {
                                acc_act.set_gicon(Icon.new_for_string(accounts_types.get(t).icon_name));
                        } catch(GLib.Error e) {
                        }
                        
                        acc_act.activate.connect(() => { //create new account
                                accounts.add_account(t, this);
                        });
                        
                        act_group.add_action(acc_act);
                        
                        accounts_string += "<menuitem action=\"%s\" />\n".printf(t.name());
                }
                
                act_group.add_action(file_menu);
                act_group.add_action(edit_menu);
                act_group.add_action(view_menu);
                act_group.add_action(help_menu);
                
                act_group.add_action(create_account_act);
                
                UIManager ui = new UIManager();
                ui.insert_action_group(act_group, 0);
                add_accel_group(ui.get_accel_group());
                
                var ui_string = """
                <ui>
                        <menubar name="MenuBar">
                                <menu action="FileMenu">
                                </menu>
                                <menu action="EditMenu">
                                        <menu action="CreateAccount">
                                                %s
                                        </menu>
                                </menu>
                                <menu action="ViewMenu">
                                </menu>
                                <menu action="HelpMenu">
                                </menu>
                        </menubar>
                </ui>
                """.printf(accounts_string);
                
                try {
                        ui.add_ui_from_string(ui_string, ui_string.length);
                } catch(GLib.Error e) {
                }
                
                menubar = ui.get_widget("/MenuBar");
        }
        
        private void signals_setup() {
                destroy.connect(() => {
                        accounts.sync();
                        
                        //settings.current_item = tree.current_tree_path.to_string();
                        
                        settings.sync();
                        main_quit();
                });
               
               /*
                tree.cursor_moved.connect((stream) => {
                        //content_view.set_current_list(hash);
                        view_area.set_current_view(stream);
                });
                */

                /*
                acc_widget.cursor_moved.connect((account, stream) => {
                    view_area.set_current_view(account, stream);
                });
                */
        }
}
