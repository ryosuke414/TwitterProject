package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class TweetImageBean implements Serializable {
	private int imageId;
	private int tweetId;
	private String imagePath;
	private String imageType;
	private Timestamp createdAt;

	public int getImageId() {
		return imageId;
	}

	public void setImageId(int imageId) {
		this.imageId = imageId;
	}

	public int getTweetId() {
		return tweetId;
	}

	public void setTweetId(int tweetId) {
		this.tweetId = tweetId;
	}

	public String getImagePath() {
		return imagePath;
	}

	public void setImagePath(String imagePath) {
		this.imagePath = imagePath;
	}

	public String getImageType() {
		return imageType;
	}

	public void setImageType(String imageType) {
		this.imageType = imageType;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}
}