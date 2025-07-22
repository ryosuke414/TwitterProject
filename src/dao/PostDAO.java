package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import bean.Post;

public class PostDAO extends TwitterDAO {

    private Post mapRow(ResultSet rs) throws SQLException {
        Post p = new Post();
        p.setTweetId(rs.getInt("tweet_id"));
        p.setUserId(rs.getInt("user_id"));
        p.setContent(rs.getString("content"));
        if (rs.getTimestamp("created_at") != null) {
            p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        p.setUsername(rs.getString("username"));
        p.setHandle(rs.getString("handle"));
        p.setProfileImage(rs.getString("profile_image"));
        p.setProfileIconW(getNullableInt(rs, "profile_icon_w"));
        p.setProfileIconH(getNullableInt(rs, "profile_icon_h"));
        p.setProfileIconX(getNullableInt(rs, "profile_icon_x"));
        p.setProfileIconY(getNullableInt(rs, "profile_icon_y"));

        if (hasColumn(rs, "reposted")) {
            p.setReposted(rs.getBoolean("reposted"));
        }
        if (hasColumn(rs, "reposted_at") && rs.getTimestamp("reposted_at") != null) {
            p.setRepostedAt(rs.getTimestamp("reposted_at").toLocalDateTime());
        }

        return p;
    }

    private Integer getNullableInt(ResultSet rs, String col) throws SQLException {
        int v = rs.getInt(col);
        return rs.wasNull() ? null : v;
    }

    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    public void create(int userId, String content) throws SQLException {
        String sql = "INSERT INTO tweets (user_id, content) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.executeUpdate();
        }
    }

    public int insert(int userId, String content) throws SQLException {
        String sql = "INSERT INTO tweets (user_id, content) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public List<Post> getTimeline(int myId) throws SQLException {
        String sql =
            "SELECT t.*, u.username, u.handle, u.profile_image, " +
            "u.profile_icon_w, u.profile_icon_h, u.profile_icon_x, u.profile_icon_y " +
            "FROM tweets t JOIN users u ON t.user_id = u.user_id " +
            "WHERE t.user_id = ? OR t.user_id IN (SELECT followed_user_id FROM followers WHERE follower_user_id = ?) " +
            "ORDER BY t.created_at DESC";

        List<Post> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, myId);
            ps.setInt(2, myId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<Post> getAllPosts() throws SQLException {
        String sql =
            "SELECT t.*, u.username, u.handle, u.profile_image, " +
            "u.profile_icon_w, u.profile_icon_h, u.profile_icon_x, u.profile_icon_y " +
            "FROM tweets t JOIN users u ON t.user_id = u.user_id " +
            "ORDER BY t.created_at DESC";

        List<Post> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public Post findById(int tweetId) throws SQLException {
        String sql =
            "SELECT t.*, u.username, u.handle, u.profile_image, " +
            "u.profile_icon_w, u.profile_icon_h, u.profile_icon_x, u.profile_icon_y " +
            "FROM tweets t JOIN users u ON t.user_id = u.user_id WHERE t.tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<Post> findAllByUserIdIncludingReposts(int userId) throws SQLException {
        String sql =
            "SELECT t.*, u.username, u.handle, u.profile_image, u.profile_icon_w, u.profile_icon_h, " +
            "u.profile_icon_x, u.profile_icon_y, false AS reposted, NULL AS reposted_at " +
            "FROM tweets t JOIN users u ON t.user_id = u.user_id WHERE t.user_id = ? " +
            "UNION ALL " +
            "SELECT t.*, u.username, u.handle, u.profile_image, u.profile_icon_w, u.profile_icon_h, " +
            "u.profile_icon_x, u.profile_icon_y, true AS reposted, r.reposted_at " +
            "FROM reposts r JOIN tweets t ON r.original_tweet_id = t.tweet_id " +
            "JOIN users u ON t.user_id = u.user_id WHERE r.user_id = ? " +
            "ORDER BY created_at DESC";

        List<Post> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countByUserId(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tweets WHERE user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<Post> findRepostsByUserId(int userId) throws SQLException {
        String sql =
            "SELECT t.*, u.username, u.handle, u.profile_image, u.profile_icon_w, u.profile_icon_h, " +
            "u.profile_icon_x, u.profile_icon_y, r.reposted_at " +
            "FROM reposts r JOIN tweets t ON r.original_tweet_id = t.tweet_id " +
            "JOIN users u ON t.user_id = u.user_id WHERE r.user_id = ? ORDER BY r.reposted_at DESC";

        List<Post> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Post p = mapRow(rs);
                    p.setReposted(true);
                    if (rs.getTimestamp("reposted_at") != null) {
                        p.setRepostedAt(rs.getTimestamp("reposted_at").toLocalDateTime());
                    }
                    list.add(p);
                }
            }
        }
        return list;
    }

    public void saveImage(int tweetId, String fileName) throws SQLException {
        String sql = "INSERT INTO tweet_images (tweet_id, file_name) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            ps.setString(2, fileName);
            ps.executeUpdate();
        }
    }

    public List<String> getImages(int tweetId) throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT file_name FROM tweet_images WHERE tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(rs.getString("file_name"));
            }
        }
        return list;
    }

    public Post getPostForEdit(int tweetId, int userId) throws SQLException {
        String sql =
            "SELECT t.*, u.username, u.handle, u.profile_image, " +
            "u.profile_icon_w, u.profile_icon_h, u.profile_icon_x, u.profile_icon_y " +
            "FROM tweets t JOIN users u ON t.user_id = u.user_id " +
            "WHERE t.tweet_id = ? AND t.user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public boolean updateContent(int tweetId, int userId, String newContent) throws SQLException {
        String sql = "UPDATE tweets SET content=? WHERE tweet_id=? AND user_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newContent);
            ps.setInt(2, tweetId);
            ps.setInt(3, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean deletePost(int tweetId, int userId) throws SQLException {
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try {
                String[] relatedDeletes = {
                    "DELETE FROM tweet_images WHERE tweet_id=?",
                    "DELETE FROM likes WHERE tweet_id=?",
                    "DELETE FROM reposts WHERE original_tweet_id=?",
                    "DELETE FROM comments WHERE tweet_id=?"
                };
                for (String sql : relatedDeletes) {
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, tweetId);
                        ps.executeUpdate();
                    }
                }
                int deleted;
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM tweets WHERE tweet_id=? AND user_id=?")) {
                    ps.setInt(1, tweetId);
                    ps.setInt(2, userId);
                    deleted = ps.executeUpdate();
                }
                con.commit();
                return deleted == 1;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<String> getImageFileNames(int tweetId) throws SQLException {
        List<String> imgs = new ArrayList<>();
        String sql = "SELECT file_name FROM tweet_images WHERE tweet_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) imgs.add(rs.getString("file_name"));
            }
        }
        return imgs;
    }
}