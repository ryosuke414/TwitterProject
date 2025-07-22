package bean;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class TweetBean implements Serializable {
    private int tweetId;
    private int userId;
    private String content;
    private Timestamp createdAt;
    private boolean pinned;

    // 表示用：ユーザー名・ハンドル名
    private String username;
    private String handle;

    // 関連画像リスト
    private List<TweetImageBean> images;

    // --- Getter / Setter ---

    public int getTweetId() {
        return tweetId;
    }

    public void setTweetId(int tweetId) {
        this.tweetId = tweetId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isPinned() {
        return pinned;
    }

    public void setPinned(boolean pinned) {
        this.pinned = pinned;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getHandle() {
        return handle;
    }

    public void setHandle(String handle) {
        this.handle = handle;
    }

    public List<TweetImageBean> getImages() {
        return images;
    }

    public void setImages(List<TweetImageBean> images) {
        this.images = images;
    }
}