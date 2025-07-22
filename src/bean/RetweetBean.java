package bean;

import java.sql.Timestamp;

public class RetweetBean {
	private int retweetId;
	private int userId;
	private int originalTweetId;
	private Timestamp createdAt;

	public int getRetweetId() {
		return retweetId;
	}

	public void setRetweetId(int retweetId) {
		this.retweetId = retweetId;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getOriginalTweetId() {
		return originalTweetId;
	}

	public void setOriginalTweetId(int originalTweetId) {
		this.originalTweetId = originalTweetId;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}
}