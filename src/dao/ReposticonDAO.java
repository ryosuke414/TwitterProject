package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ReposticonDAO extends TwitterDAO {

    /** リポスト数を取得 */
    public int countReposts(int tweetId) throws SQLException {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM reposts WHERE original_tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) count = rs.getInt(1);
            }
        }
        return count;
    }

    /** 指定ユーザーがリポストしているか確認 */
    public boolean isReposted(int userId, int tweetId) throws SQLException {
        String sql = "SELECT 1 FROM reposts WHERE user_id = ? AND original_tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** リポスト登録 */
    public void addRepost(int userId, int tweetId) throws SQLException {
        String sql = "INSERT INTO reposts (user_id, original_tweet_id) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();
        }
    }

    /** リポスト解除 */
    public void removeRepost(int userId, int tweetId) throws SQLException {
        String sql = "DELETE FROM reposts WHERE user_id = ? AND original_tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();
        }
    }
}