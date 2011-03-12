using Gtk;

public class Thumb : EventBoxTr {
	
	private string full_url;
	
	public Thumb(string url, int size, string? full_url) {
		this.full_url = full_url;
		
		Avatar img = new Avatar.from_url(url, size);
		add(img);
		
		button_release_event.connect(on_click);
		
		if(full_url != null)
			img.set_tooltip_text(full_url);
	}
	
	private bool on_click(Gdk.EventButton event) {
		GLib.Pid pid;
		try {
			GLib.Process.spawn_async(".", {"/usr/bin/xdg-open", full_url},
				null, GLib.SpawnFlags.STDOUT_TO_DEV_NULL, null, out pid);
		} catch (GLib.SpawnError e) {
			stderr.printf("%s\n", e.message);
		}
		
		return true;
	}
}
