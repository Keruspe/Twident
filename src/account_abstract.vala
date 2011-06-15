using Gee;
using TwidentEnums;
using Gtk;

/** Abstract class for any account in this app */
public abstract class AAccount : GLib.Object {

        public signal void stream_was_added(AAccount account, AStream stream);
        public signal void stream_was_removed(AAccount account, AStream stream);
        public signal void fresh_items_changed(int items, int stream_index, AAccount account);
        public signal void account_was_changed(AAccount account);
        public signal void status_sent(AAccount account, bool ok, string error_msg = "");
        public signal void message_indicate(string msg);
        public signal void stop_indicate();
        public signal void do_reply(AAccount account, Status status);
        public signal void insert_reply(string stream_hash, string status_id, Status result);
        public signal void cursor_changed(AStream? new_stream, AStream? old_stream);
        
        /* For tree widget */
        public signal void stream_was_changed(AAccount account, AStream stream, int stream_index);
        
        /** For updating list content */
        public signal void stream_was_updated(string hash, AStream stream);
        
        /** Userpic */
        //private Gdk.Pixbuf? _userpic = null;
        public Gdk.Pixbuf? userpic {get; set; default = null;}
        public string s_avatar_url {get; set; default = "";}
        
        /** Holdes list of current streams */
        //private ArrayList<AStream> _streams = new ArrayList<AStream>();
        public StreamsModel streams {get; set; default = new StreamsModel(); }
        
        /** Items in context menu of this account */
        public abstract MenuItems[] popup_items {owned get;}
        
        /** Items in statuses context menu */
        public abstract StatusMenuItems[] status_popup_items {owned get;}
        
        /** All streams wich can be added to this account */
        public abstract HashMap<StreamEnum, GLib.Type> avaliable_streams();// {owned get;}

        /** Default number of streams for account */
        protected abstract StreamEnum[] default_streams {owned get;}

        /** Account setup, must contain stream_setup */
        //public abstract void set_properties(AccountState state);
        
        public virtual string s_name {get; set; default = "unknown";}
        
        /** Update interval in secs */
        public virtual int s_update_interval {get; set; default = 3000;}
        
        /** Account string id */
        public abstract string id {get; set;}
        
        /** Account unique hash */
        public string s_hash {get; set; default = "";}
        
        public string get_hash() {
                if(s_hash == "") {
                        TimeVal t = TimeVal();
                        t.get_current_time();
                        s_hash = t.tv_usec.to_string() + Random.int_range(10000, 99999).to_string();
                }
                
                return "%s::%s::%s".printf(id, s_name, s_hash);
        }
        
        /** Send status */
        public virtual void send_status(string status_text, string reply_id) {
        }
        
        /** Do something after creating */
        public virtual void post_install() {
        
        }
        
        construct {
                notify["userpic"].connect((s) => {
                        account_was_changed(this);
                });

                streams.cursor_changed.connect((new_stream, old_stream) => {
                    cursor_changed(new_stream, old_stream);
                });
        }
        
        /** Unique hash of stream+account */
        public string get_stream_hash(AStream stream) {
                if(stream.s_hash == "") {
                        TimeVal t = TimeVal();
                        t.get_current_time();
                        stream.s_hash = t.tv_usec.to_string() + Random.int_range(10000, 99999).to_string(); //this is how we generate unique hash
                }
                return "%s::%s::%s::%s".printf(id, s_name, stream.id, stream.s_hash);
        }
        
        /** Unique hash from stream index + account 
        public string get_stream_hash_indexed(int index) {
                
        }*/
        
        /** Init new account by dialog */
        public virtual bool create(Gtk.Window w) {
                setup_default_streams();
                return true;
        }
        
        /** Create default streams from scratch */
        public void setup_default_streams() {
                foreach(StreamEnum stream_type in default_streams) {
                        add_stream(stream_type, true);
                }
        }
        
        /** Add new stream */
        public void add_stream(StreamEnum stream_type, bool emit_signal = false,
                HashMap<string, string>? props = null) {
                
                Type? stype = null;
                stype = avaliable_streams().get(stream_type);//streams_types.get_type_by_string(state.stream_type);
                        
                if(stype == null) {
                        warning("Stream type is not supported");
                        return;
                }

                AStream stream = (AStream) GLib.Object.new(stype);
                stream.account = this;
                
                if(props != null) {
                        var obj = (ObjectClass) stype.class_ref();
                        
                        foreach(var p in obj.list_properties()) {
                                string? pval = props.get(p.get_name());
                        
                                if(pval == null)
                                        continue;
                        
                                Value? val = Accounts.value_from_string(pval, p.value_type);
                        
                                if(val == null) {
                                        continue;
                                }
                        
                                stream.set_property(p.get_name(), val);
                        }
                }
                
                //count of fresh items is was changed
                stream.notify["fresh-items"].connect((s) => {
                        stream_was_changed(this, stream, streams.index_of(stream));
                });
                
                stream.notify["status"].connect((s) => {
                        stream_was_changed(this, stream, streams.index_of(stream));
                });
                
                stream.updated.connect(() => {
                        stream_was_updated(get_stream_hash(stream), stream);
                });
                
                if(emit_signal) {
                        //stream_was_added(this, stream);
                }
                
                init_stream(stream);

                streams.add(stream);
        }
        
        /** If we need to add some options to the stream */
        protected virtual void init_stream(AStream stream) {
        }
        
        /** Create list of streams from restored state */
        protected virtual void streams_setup(ArrayList<StreamState> streams_states) {
                foreach(StreamState state in streams_states) {
                        add_stream(state.stream_type);
                }
        }
        
        /** Reaction on stream's popup menu actions */
        public void streams_actions_tracker(AStream stream, MenuItems item) {
                switch(item) {
                case MenuItems.REMOVE:
                        //stream_was_removed(this, stream);
                        streams.remove(stream);
                        break;
                
                case MenuItems.REFRESH:
                        stream.menu_refresh();
                        break;
                
                case MenuItems.SETTINGS:
                        stream.menu_settings();
                        break;
                
                case MenuItems.MORE:
                        stream.menu_more();
                        break;
                }
        }
        
        /** Return status from some stream */
        /*
        protected Status? get_status(StreamEnum stype, string status_id) {
                foreach(AStream stream in streams) {
                        if(stream.stream_type != stype)
                                continue;
                        
                        return get_status_from_stream(stream, status_id);
                        
                        break;
                }
                
                return null;
        }*/
        
        /** Return all statuses with some id */
        protected ArrayList<Status> get_statuses(string status_id) {
                ArrayList<Status> lst = new ArrayList<Status>();
                foreach(AStream stream in streams) {
                        Status? status = get_status_from_stream(stream, status_id);
                        if(status != null)
                                lst.add(status);
                        
                        lst.add_all(get_child_statuses(stream, status_id));
                }
                
                return lst;
        }
        
        /** Remove status from all streams */
        protected void remove_status_complete(string status_id) {
                foreach(AStream stream in streams) {
                        Status? status = get_status_from_stream(stream, status_id);
                        if(status != null) {
                                stream.model.remove(status);
                                
                                //stream.menu_refresh();
                        }
                        
                        //remove_child_statuses(stream, status_id);
                }
        }
        
        /* TODO
        protected void remove_child_statuses(AStream stream, string status_id) {
                foreach(Status status in stream.model) {
                        if(status.conversation != null) {
                                foreach(Status cstatus in status.conversation) {
                                        if(cstatus.id == status_id)
                                                status.conversation.remove(cstatus);
                                }
                        }
                }
        }*/
        
        protected ArrayList<Status> get_child_statuses(AStream stream, string status_id) {
                ArrayList<Status> lst = new ArrayList<Status>();
                
                foreach(Status status in stream.model) {
                        if(status.conversation != null) {
                                foreach(Status cstatus in status.conversation) {
                                        if(cstatus.id == status_id)
                                                lst.add(cstatus);
                                }
                        }
                }
                
                return lst;
        }
        
        protected Status? get_status_from_stream(AStream stream, string status_id) {
                foreach(Status status in stream.model) {
                        if(status.id == status_id) {
                                return status;
                        }
                }
                
                return null;
        }
        
        /** Action from content view */
        public virtual AStream? new_content_action(string action_type,
                string stream_hash, string val) {
                
                AStream? stream = null;
                foreach(AStream s in streams) {
                        if(s.s_hash == stream_hash) {
                                stream = s;
                                break;
                        }
                }
                
                return stream;
        }
        
        /** Show status context menu */
        public virtual void context_menu(AStream stream, Status status) {
                Menu menu = new Menu();
                
                foreach(StatusMenuItems item in status_popup_items) {
                        ImageMenuItem? menu_item = null;
                        
                        
                        switch(item) {
                        case StatusMenuItems.REPLY:
                                if(status.own)
                                        break;
                                
                                Image? img = new Image.from_stock("gtk-undo", IconSize.MENU);
                                menu_item = new ImageMenuItem.with_label(_("Reply"));
                                menu_item.set_image(img);
                                menu_item.activate.connect(() => menu_do_reply(status));
                                break;
                        
                        case StatusMenuItems.FAVORITE:
                                string label = "";
                                Image? img = new Image.from_stock("gtk-about", IconSize.MENU);
                                
                                if(status.favorited)
                                        label = _("Remove from favorites");
                                else
                                        label = _("Add to favorites");
                                
                                menu_item = new ImageMenuItem.with_label(label);
                                menu_item.set_image(img);
                                menu_item.activate.connect(() => menu_do_favorite(status));
                                break;
                        
                        case StatusMenuItems.RETWEET:
                                if(status.own)
                                        break;
                                
                                Image img = new Image.from_file(Config.RETWEET_PATH);
                                menu_item = new ImageMenuItem.with_label(_("Retweet"));
                                menu_item.set_image(img);
                                menu_item.activate.connect(() => menu_do_retweet(status));
                                break;
                        
                        case StatusMenuItems.REMOVE:
                                if(!status.own)
                                        break;
                                
                                Image img = new Image.from_stock("gtk-remove", IconSize.MENU);
                                menu_item = new ImageMenuItem.with_label(_("Delete"));
                                menu_item.set_image(img);
                                menu_item.activate.connect(() => menu_do_remove(status));
                                break;
                        }
                        
                        
                        if(menu_item != null)
                                menu.add(menu_item);
                }
                
                
                menu.popup(null, null, null, 0, 0);
                menu.show_all();
        }
        
        public virtual void get_conversation(Status status) {}
        
        public virtual void go_hashtag(string tag) {}
        
        public virtual void go_group(string group_name) {}
        
        /** Virtual context menu actions */
        protected virtual void menu_do_reply(Status status) {}
        
        protected virtual void menu_do_favorite(Status status) {}
        
        protected virtual void menu_do_retweet(Status status) {}
        
        protected virtual void menu_do_remove(Status status) {}
}
