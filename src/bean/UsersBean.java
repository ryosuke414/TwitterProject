package bean;

import java.io.Serializable;

public class UsersBean implements Serializable{
	private String username;
	private String handle;
	private String email;
	private String password;
	private String bio;
	private String profile_image;
	private boolean is_active;


	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}

	public String getHandle(){
		return handle;
	}
	public void setHandle(String handle) {
		this.handle = handle;
	}

	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}

	public String getBio() {
		return bio;
	}
	public void setBio(String bio) {
		this.bio = bio;
	}

	public String getProfile_image() {
		return profile_image;
	}
	public void setProfile_image(String profile_image) {
		this.profile_image = profile_image;
	}

	public boolean getIs_active() {
		return is_active;
	}
	public void setIs_active(boolean is_active) {
		this.is_active = is_active;
	}

}