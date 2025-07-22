package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class RepostDAO extends TwitterDAO {

    /** リポスト登録（既にあれば無視してOK） */
    public void addRepost(int userId, int tweetId) throws SQLException {
        String sql = "INSERT INTO reposts (user_id, original_tweet_id) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();

        } catch (SQLException e) {
            // UNIQUE制約違反（重複）なら無視、それ以外は再スロー
            if (!isDuplicateKey(e)) throw e;
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

    /** 指定ユーザーがリポスト済みか */
    public boolean isReposted(int userId, int tweetId) throws SQLException {
        String sql = "SELECT 1 FROM reposts WHERE user_id = ? AND original_tweet_id = ? LIMIT 1";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** ツイートのリポスト数を取得 */
    public int countReposts(int tweetId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reposts WHERE original_tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** 重複INSERTかどうか簡易判定（DB種別に応じて調整可能） */
    private boolean isDuplicateKey(SQLException e) {
        // MySQL: SQLState 23000（重複主キー違反）、H2: 23505など
        String state = e.getSQLState();
        return "23000".equals(state) || "23505".equals(state);
    }
}