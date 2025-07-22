package bean;

import java.sql.Timestamp;

public class FollowBean {
	private int followId;
	private int followerId;
	private int followeeId;
	private Timestamp createdAt;

	public int getFollowId() {
		return followId;
	}

	public void setFollowId(int followId) {
		this.followId = followId;
	}

	public int getFollowerId() {
		return followerId;
	}

	public void setFollowerId(int followerId) {
		this.followerId = followerId;
	}

	public int getFolloweeId() {
		return followeeId;
	}

	public void setFolloweeId(int followeeId) {
		this.followeeId = followeeId;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}
}