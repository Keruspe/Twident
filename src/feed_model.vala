using Gee;

/** List, that can connect to some feed view */
public class FeedModel : ArrayList<Status> {
	
	public signal void status_added(Status status);
	public signal void status_inserted(int index, Status status, AStream stream);
	public signal void status_removed(int index);
	
	public AStream? stream = null;
	
	public override bool add(Status status) {
		bool answer = base.add(status);
		
		status_added(status); //emit
		
		return answer;
	}
	
	public override void insert(int index, Status status) {
		base.insert(index, status);
		status_inserted(index, status, stream); //emit
	}
	
	public new bool add_all(Collection<Status> lst) {
		int i = 0;
		foreach(Status status in lst) {
			insert(i, status);
			i += 1;
		}
		
		return true;
	}
	
	public override bool remove(Status status) {
		int index = index_of(status);
		bool answer = base.remove(status);
		
		status_removed(index); //emit
		
		return answer;
	}
	
	public override Status remove_at(int index) {
		Status status = base.remove_at(index);
		
		status_removed(index); //emit
		
		return status;
	}
}
