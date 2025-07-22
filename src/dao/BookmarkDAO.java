package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BookmarkDAO extends TwitterDAO {

    public void addBookmark(int userId, int tweetId) throws SQLException {
        String sql = "INSERT INTO bookmarks (user_id, tweet_id) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();
        }
    }

    public void removeBookmark(int userId, int tweetId) throws SQLException {
        String sql = "DELETE FROM bookmarks WHERE user_id = ? AND tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();
        }
    }

    public boolean isBookmarked(int userId, int tweetId) throws SQLException {
        String sql = "SELECT 1 FROM bookmarks WHERE user_id = ? AND tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<Integer> getBookmarkedTweetIds(int userId) throws SQLException {
        String sql = "SELECT tweet_id FROM bookmarks WHERE user_id = ?";
        List<Integer> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("tweet_id"));
                }
            }
        }
        return list;
    }
}