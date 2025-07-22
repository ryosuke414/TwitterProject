// Post bean
package bean;

import java.time.LocalDateTime;

public class Post {
    private int tweetId;
    private int userId;
    private String content;
    private LocalDateTime createdAt;
    private String profileImage;

    // join 用
    private String username;
    private String handle;

    private boolean reposted = false;
    private LocalDateTime repostedAt;

    private Integer profileIconW;
    private Integer profileIconH;
    private Integer profileIconX;
    private Integer profileIconY;

    /* getters / setters */
    public int getTweetId() { return tweetId; }
    public void setTweetId(int tweetId) { this.tweetId = tweetId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getHandle() { return handle; }
    public void setHandle(String handle) { this.handle = handle; }


    public boolean isReposted() {
        return reposted;
    }

    public void setReposted(boolean reposted) {
        this.reposted = reposted;
    }

    public LocalDateTime getRepostedAt() {
        return repostedAt;
    }

    public void setRepostedAt(LocalDateTime repostedAt) {
        this.repostedAt = repostedAt;
    }

//    public String getProfileImage() {
//        return profileImage;
//    }

//    public void setProfileImage(String profileImage) {
//        this.profileImage = profileImage;
//    }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String v) { this.profileImage = v; }
    public Integer getProfileIconW() { return profileIconW; }
    public void setProfileIconW(Integer v){ this.profileIconW = v; }
    public Integer getProfileIconH() { return profileIconH; }
    public void setProfileIconH(Integer v){ this.profileIconH = v; }
    public Integer getProfileIconX() { return profileIconX; }
    public void setProfileIconX(Integer v){ this.profileIconX = v; }
    public Integer getProfileIconY() { return profileIconY; }
    public void setProfileIconY(Integer v){ this.profileIconY = v; }

}
