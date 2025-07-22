package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.Post;
import bean.User;

public class SearchDAO extends TwitterDAO {

    public List<Post> searchPosts(String keyword) throws SQLException {
        String sql =
            "SELECT t.tweet_id, t.user_id, t.content, t.created_at, " +
            "       u.username, u.handle, " +
            "       u.profile_image, u.profile_icon_w, u.profile_icon_h, " +
            "       u.profile_icon_x, u.profile_icon_y " +
            "FROM tweets t " +
            "JOIN users u ON t.user_id = u.user_id " +
            "WHERE (t.content LIKE ? OR u.username LIKE ? OR u.handle LIKE ?) " +
            "ORDER BY t.created_at DESC";

        List<Post> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Post p = new Post();
                    p.setTweetId(rs.getInt("tweet_id"));
                    p.setUserId(rs.getInt("user_id"));
                    p.setContent(rs.getString("content"));
                    p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    p.setUsername(rs.getString("username"));
                    p.setHandle(rs.getString("handle"));
                    p.setProfileImage(rs.getString("profile_image"));

                    int w = rs.getInt("profile_icon_w");
                    if (!rs.wasNull()) p.setProfileIconW(w);
                    int h = rs.getInt("profile_icon_h");
                    if (!rs.wasNull()) p.setProfileIconH(h);
                    int x = rs.getInt("profile_icon_x");
                    if (!rs.wasNull()) p.setProfileIconX(x);
                    int y = rs.getInt("profile_icon_y");
                    if (!rs.wasNull()) p.setProfileIconY(y);

                    list.add(p);
                }
            }
        }
        return list;
    }

    public void saveHistory(int userId, String keyword) throws SQLException {
        String sql =
            "MERGE INTO search_history (user_id, keyword, searched_at) " +
            "KEY (user_id, keyword) " +
            "VALUES (?, ?, CURRENT_TIMESTAMP)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, keyword);
            ps.executeUpdate();
        }
    }

    public List<String> getHistory(int userId) throws SQLException {
        String sql =
            "SELECT keyword FROM search_history " +
            "WHERE user_id = ? " +
            "ORDER BY searched_at DESC";

        List<String> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("keyword"));
                }
            }
        }
        return list;
    }

    /** 履歴をすべて削除 */
    public void clearHistory(int userId) throws SQLException {
        String sql = "DELETE FROM search_history WHERE user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    /** 指定キーワードのみ削除 */
    public void deleteHistory(int userId, String keyword) throws SQLException {
        String sql = "DELETE FROM search_history WHERE user_id = ? AND keyword = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, keyword);
            ps.executeUpdate();
        }
    }

    /** ユーザー検索 */
    public List<User> searchUsers(String keyword) throws SQLException {
        String sql =
            "SELECT user_id FROM users " +
            "WHERE username LIKE ? OR handle LIKE ? " +
            "ORDER BY user_id";

        List<User> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);

            try (ResultSet rs = ps.executeQuery()) {
                UserDAO udao = new UserDAO();
                while (rs.next()) {
                    list.add(udao.findById(rs.getInt("user_id")));
                }
            }
        }
        return list;
    }
}