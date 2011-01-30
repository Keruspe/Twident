using Gee;

/**
 * Holder all properties of existing account
 * Need for restoring from config
 */
public class AccountState : HashMap<string, string> {

	public string account_type {get; set;}
	public ArrayList<StreamState> streams {get; set;}
	
	public AccountState() {
		streams = new ArrayList<StreamState>();
	}
}
