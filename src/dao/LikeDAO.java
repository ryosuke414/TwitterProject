package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LikeDAO extends TwitterDAO {

    // いいねをトグル（既にいいねしていれば削除、していなければ追加）
    public void toggleLike(int userId, int tweetId) throws SQLException {
        if (isLiked(userId, tweetId)) {
            removeLike(userId, tweetId);
        } else {
            addLike(userId, tweetId);
        }
    }

    // いいねしているか確認
    public boolean isLiked(int userId, int tweetId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM likes WHERE user_id = ? AND tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // いいねを追加
    public void addLike(int userId, int tweetId) throws SQLException {
        String sql = "INSERT INTO likes (user_id, tweet_id) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();
        }
    }

    // いいねを削除
    public void removeLike(int userId, int tweetId) throws SQLException {
        String sql = "DELETE FROM likes WHERE user_id = ? AND tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tweetId);
            ps.executeUpdate();
        }
    }

    // 特定の投稿のいいね数を取得
    public int countLikes(int tweetId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM likes WHERE tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}