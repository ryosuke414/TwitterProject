// Comment.java
package bean;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Comment {
    private int commentId;
    private int tweetId;
    private int userId;
    private String content;
    private LocalDateTime createdAt;
    private String profileImage;
    private Integer profileIconW;
    private Integer profileIconH;
    private Integer profileIconX;
    private Integer profileIconY;


    // 表示用
    private String username;
    private String handle;

    private Integer parentCommentId;
    private boolean deleted;
    private List<Comment> replies; // ツリー構築用（必要な場合）

    // Getters and Setters
    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

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

//    public String getProfileImage() {
//        return profileImage;
//    }

//    public void setProfileImage(String profileImage) {
//        this.profileImage = profileImage;
//    }

    public Integer getParentCommentId() { return parentCommentId; }
    public void setParentCommentId(Integer v) { this.parentCommentId = v; }

    public boolean isDeleted() { return deleted; }
    public void setDeleted(boolean d) { this.deleted = d; }

    public List<Comment> getReplies() {
        if (replies == null) replies = new ArrayList<>();
        return replies;
    }
    public void addReply(Comment c) { getReplies().add(c); }

    public void setReplies(List<Comment> replies) {
        this.replies = replies;
    }

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
