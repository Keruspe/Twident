using Gtk;

/** Here we view all our statuses from one feed */
public class FeedView : ScrolledWindow {
	
	private VBox vbox;
	private FeedModel model;
	private VScrollbar scroll;
	
	public FeedView() {
		set_policy(PolicyType.AUTOMATIC, PolicyType.ALWAYS);
		
		vbox = new VBox(false, 2);
		add_with_viewport(vbox);

                //remove border from viewport
                ((Viewport) get_child()).set_shadow_type(ShadowType.NONE);
		
		scroll = (VScrollbar) get_vscrollbar();
		scroll.value_changed.connect(() => {
			
			double max = scroll.adjustment.upper;
			double current = scroll.get_value();
			double scroll_size = scroll.adjustment.page_size;
			
			if(current != 0 && current + scroll_size == max) {
				if(model.stream != null) {
					model.stream.menu_more();
				}
			}
		});
	}
	
	public void set_model(FeedModel model) {
		this.model = model;
		
		foreach(Status status in model) {
			add_item(status, model.stream);
		}
		
		this.model.status_added.connect((status) => { add_item(status, model.stream); });
		this.model.status_inserted.connect(insert_item);
		this.model.status_removed.connect(remove_item);
	}
	
	private StatusDelegate new_delegate(Status status, AStream stream) {
		StatusDelegate widget = new StatusDelegate(status, stream);
		widget.show_all();
		return widget;
	}
	
	public StatusDelegate add_item(Status status, AStream stream) {
		StatusDelegate widget = new_delegate(status, stream);
		vbox.pack_start(widget, false, false, 0);
		
		return widget;
	}
	
	public void insert_item(int index, Status status, AStream stream) {
		StatusDelegate widget = add_item(status, stream);
		vbox.reorder_child(widget, index);
	}
	
	public void remove_item(int index) {
		Widget widget = vbox.get_children().nth_data(index);
		vbox.remove(widget);
	}
}
