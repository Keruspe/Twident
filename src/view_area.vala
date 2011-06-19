using Gtk;
using Gee;

public class ViewArea : VBox {
	
	private Accounts accounts;
	private HashMap<AStream, FeedView> feeds;
	//private AStream current_stream;
	
	public ViewArea(Accounts accounts) {
		this.accounts = accounts;
		
		feeds = new HashMap<AStream, FeedView>();
		
		homogeneous = true;
		spacing = 0;
	
                accounts.account_was_removed.connect((account) => {
                    foreach(AStream st in account.streams) {
                        remove_feed_view(st);
                    }
		});
		accounts.insert_new_account.connect(account_setup);
		}
		
		public void generate_views() {
		foreach(AAccount account in accounts) {
		account_setup(account);
		}
		}
		
		private void account_setup(AAccount? account) {
		if(account == null)
		return;
		
		foreach(AStream stream in account.streams) {
		create_feed_view(stream);
		}
		
		account.streams.removed.connect(remove_feed_view);
		
		account.streams.cursor_changed.connect((new_stream, old_stream) => {
                    if(new_stream == null)
                        return; //TODO

                    set_current_view(new_stream.account, new_stream, old_stream);
                });
                account.streams.added.connect((stream) => {
		FeedView view = create_feed_view(stream);
		view.show_all();
		//set_current_view(stream.account, stream);
		});
	}
	
	private void remove_feed_view(AStream stream) {
		FeedView view = feeds[stream];
		remove(view);
		feeds.unset(stream);
		
                view.dispose();
		//if(stream == current_stream)
		//	current_stream.dispose();
	}
	
	private FeedView create_feed_view(AStream stream) {
		FeedView view = new FeedView();
		
		view.set_model(stream.model);
		
		feeds[stream] = view;
		
		pack_start(view, true, true, 0);
		view.hide();
		
		return view;
	}
	
	public void set_current_view(AAccount? account, AStream? stream, AStream? old_stream) {
		//if(stream == current_stream)
		//	return;

                if(stream == null) {
                    return;/*
                    if(account.streams.size < 1)
                        return;
                    stream = account.streams.get(0);*/
                }
		
                if(old_stream != null)
                    feeds[old_stream].hide();
                //current_stream = stream;
                feeds[stream].show_all();
		//view.show_all();
	}
}
