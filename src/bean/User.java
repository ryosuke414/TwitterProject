package bean;

public class User {
    private int userId;
    private String username;    // 表示名
    private String handle;      // @ユーザー名
    private String password;    // パスワード（ハッシュ化前提）
    private String bio;         // 自己紹介
    private String profileImage;

    // 画像編集関連
    private Integer profileIconW;
    private Integer profileIconH;
    private Integer profileIconX;
    private Integer profileIconY;

    // 表示用スケーリング後のサイズ
    private Integer displayWidth;
    private Integer displayHeight;
    private String originalImage;

    /* --- getters / setters --- */
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getHandle() { return handle; }
    public void setHandle(String handle) { this.handle = handle; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }

    public Integer getProfileIconW() { return profileIconW; }
    public void setProfileIconW(Integer profileIconW) { this.profileIconW = profileIconW; }

    public Integer getProfileIconH() { return profileIconH; }
    public void setProfileIconH(Integer profileIconH) { this.profileIconH = profileIconH; }

    public Integer getProfileIconX() { return profileIconX; }
    public void setProfileIconX(Integer profileIconX) { this.profileIconX = profileIconX; }

    public Integer getProfileIconY() { return profileIconY; }
    public void setProfileIconY(Integer profileIconY) { this.profileIconY = profileIconY; }

    public Integer getDisplayWidth() { return displayWidth; }
    public void setDisplayWidth(Integer displayWidth) { this.displayWidth = displayWidth; }

    public Integer getDisplayHeight() { return displayHeight; }
    public void setDisplayHeight(Integer displayHeight) { this.displayHeight = displayHeight; }

    public String getOriginalImage() { return originalImage; }
    public void setOriginalImage(String originalImage) { this.originalImage = originalImage; }
}
