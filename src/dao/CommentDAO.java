package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.Comment;

public class CommentDAO extends TwitterDAO {

    /**
     * 指定ツイート（tweetId）のコメント一覧取得（親コメントと子コメントを階層構造で取得）
     * ページング付き（limit/offset対応）
     */
    public List<Comment> getRootCommentsForTweet(int tweetId, int offset, int limit) throws SQLException {
        String sql =
            "SELECT c.*, u.username, u.handle, u.profile_image " +
            "FROM comments c " +
            "JOIN users u ON c.user_id = u.user_id " +
            "WHERE c.tweet_id = ? AND c.parent_comment_id IS NULL " +
            "ORDER BY c.created_at ASC " +
            "LIMIT ? OFFSET ?";

        List<Comment> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tweetId);
            ps.setInt(2, limit);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment c = mapRow(rs);
                    // 子コメントを取得
                    c.setReplies(getReplies(c.getCommentId()));
                    list.add(c);
                }
            }
        }
        return list;
    }

    /**
     * 子コメント一覧を取得（1階層）
     */
    public List<Comment> getReplies(int parentCommentId) throws SQLException {
        String sql =
            "SELECT c.*, u.username, u.handle, u.profile_image " +
            "FROM comments c " +
            "JOIN users u ON c.user_id = u.user_id " +
            "WHERE c.parent_comment_id = ? " +
            "ORDER BY c.created_at ASC";

        List<Comment> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, parentCommentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment c = mapRow(rs);
                    list.add(c);
                }
            }
        }
        return list;
    }

    /**
     * 通常コメント追加
     */
    public void insert(Comment c) throws SQLException {
        String sql = "INSERT INTO comments (tweet_id, user_id, content) VALUES (?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, c.getTweetId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getContent());
            ps.executeUpdate();
        }
    }

    /**
     * 返信コメント追加
     */
    public void insertReply(Comment c) throws SQLException {
        String sql = "INSERT INTO comments (tweet_id, user_id, content, parent_comment_id) VALUES (?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, c.getTweetId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getContent());
            ps.setInt(4, c.getParentCommentId());
            ps.executeUpdate();
        }
    }

    /**
     * コメント単体取得
     */
    public Comment findById(int commentId) throws SQLException {
        String sql =
            "SELECT c.*, u.username, u.handle, u.profile_image " +
            "FROM comments c " +
            "JOIN users u ON c.user_id = u.user_id " +
            "WHERE c.comment_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * コメント削除（ユーザー本人のみ）
     */
    public void delete(int commentId, int userId) throws SQLException {
        String sql = "DELETE FROM comments WHERE comment_id = ? AND user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /**
     * コメント数（親コメント含む全体）
     */
    public int countByTweet(int tweetId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM comments WHERE tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * 共通マッピング
     */
    private Comment mapRow(ResultSet rs) throws SQLException {
        Comment c = new Comment();
        c.setCommentId(rs.getInt("comment_id"));
        c.setTweetId(rs.getInt("tweet_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setContent(rs.getString("content"));
        if (rs.getTimestamp("created_at") != null) {
            c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        c.setUsername(rs.getString("username"));
        c.setHandle(rs.getString("handle"));
        c.setProfileImage(rs.getString("profile_image"));
        c.setParentCommentId((Integer) rs.getObject("parent_comment_id")); // null可
        return c;
    }
}