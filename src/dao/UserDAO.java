package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.User;

public class UserDAO extends TwitterDAO {

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setHandle(rs.getString("handle"));
        u.setPassword(rs.getString("password"));
        u.setBio(rs.getString("bio"));
        u.setProfileImage(rs.getString("profile_image"));
        u.setOriginalImage(rs.getString("original_image"));

        u.setProfileIconW(getNullableInt(rs, "profile_icon_w"));
        u.setProfileIconH(getNullableInt(rs, "profile_icon_h"));
        u.setProfileIconX(getNullableInt(rs, "profile_icon_x"));
        u.setProfileIconY(getNullableInt(rs, "profile_icon_y"));
        u.setDisplayWidth(getNullableInt(rs, "display_w"));
        u.setDisplayHeight(getNullableInt(rs, "display_h"));

        return u;
    }

    private Integer getNullableInt(ResultSet rs, String col) throws SQLException {
        int v = rs.getInt(col);
        return rs.wasNull() ? null : v;
    }

    public User findByHandleAndPassword(String handle, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE handle = ? AND password = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, handle);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapUser(rs) : null;
            }
        }
    }

    public User findById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapUser(rs) : null;
            }
        }
    }

    public List<User> getAllExcept(int myId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id != ?";
        List<User> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, myId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        }
        return list;
    }

    public void insertUser(String username, String handle, String password,
                           String bio, String profileImage) throws SQLException {
        String sql = "INSERT INTO users(username, handle, password, bio, profile_image) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, handle);
            ps.setString(3, password);
            ps.setString(4, bio);
            ps.setString(5, profileImage);
            ps.executeUpdate();
        }
    }

    public void updateProfile(int userId, String username, String bio, String profileImage) throws SQLException {
        String sql = "UPDATE users SET username=?, bio=?, profile_image=? WHERE user_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, bio);
            ps.setString(3, profileImage);
            ps.setInt(4, userId);
            ps.executeUpdate();
        }
    }

    public void updateProfile(int userId, String username, String bio) throws SQLException {
        String sql = "UPDATE users SET username=?, bio=? WHERE user_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, bio);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    public void updateProfileWithLayout(
            int userId,
            String username,
            String bio,
            String profileImage,
            Integer w, Integer h, Integer x, Integer y,
            Integer displayW, Integer displayH,
            String originalImage
    ) throws SQLException {

        StringBuilder sb = new StringBuilder();
        sb.append("UPDATE users SET username=?, bio=?");
        if (profileImage != null) sb.append(", profile_image=?");
        if (originalImage != null) sb.append(", original_image=?");
        if (w != null) sb.append(", profile_icon_w=?");
        if (h != null) sb.append(", profile_icon_h=?");
        if (x != null) sb.append(", profile_icon_x=?");
        if (y != null) sb.append(", profile_icon_y=?");
        if (displayW != null) sb.append(", display_w=?");
        if (displayH != null) sb.append(", display_h=?");
        sb.append(" WHERE user_id=?");

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {

            int idx = 1;
            ps.setString(idx++, username);
            ps.setString(idx++, bio);
            if (profileImage != null) ps.setString(idx++, profileImage);
            if (originalImage != null) ps.setString(idx++, originalImage);
            if (w != null) ps.setInt(idx++, w);
            if (h != null) ps.setInt(idx++, h);
            if (x != null) ps.setInt(idx++, x);
            if (y != null) ps.setInt(idx++, y);
            if (displayW != null) ps.setInt(idx++, displayW);
            if (displayH != null) ps.setInt(idx++, displayH);
            ps.setInt(idx++, userId);

            ps.executeUpdate();
        }
    }

    public List<User> findFollowingUsers(int userId) throws SQLException {
        String sql =
            "SELECT u.* FROM followers f " +
            "JOIN users u ON f.followed_user_id = u.user_id " +
            "WHERE f.follower_user_id = ? " +
            "ORDER BY u.user_id ";
        List<User> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapUser(rs));
            }
        }
        return list;
    }

    public List<User> findFollowerUsers(int userId) throws SQLException {
        String sql =
            "SELECT u.* FROM followers f " +
            "JOIN users u ON f.follower_user_id = u.user_id " +
            "WHERE f.followed_user_id = ? " +
            "ORDER BY u.user_id ";
        List<User> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapUser(rs));
            }
        }
        return list;
    }

}