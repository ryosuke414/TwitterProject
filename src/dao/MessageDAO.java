package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.Message;
import bean.User;

public class MessageDAO extends TwitterDAO {

    public List<Message> getConversation(int userId1, int userId2) throws SQLException {
        String sql =
            "SELECT m.*, u1.handle AS fromHandle, u2.handle AS toHandle " +
            "FROM messages m " +
            "JOIN users u1 ON m.from_user_id = u1.user_id " +
            "JOIN users u2 ON m.to_user_id = u2.user_id " +
            "WHERE (from_user_id = ? AND to_user_id = ?) " +
            "   OR (from_user_id = ? AND to_user_id = ?) " +
            "ORDER BY sent_at";

        List<Message> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId1);
            ps.setInt(2, userId2);
            ps.setInt(3, userId2);
            ps.setInt(4, userId1);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Message m = new Message();
                m.setMessageId(rs.getInt("message_id"));
                m.setFromUserId(rs.getInt("from_user_id"));
                m.setToUserId(rs.getInt("to_user_id"));
                m.setContent(rs.getString("content"));
                m.setSentAt(rs.getTimestamp("sent_at").toLocalDateTime());
                m.setFromHandle(rs.getString("fromHandle"));
                m.setToHandle(rs.getString("toHandle"));
                list.add(m);
            }
        }
        return list;
    }

    public void sendMessage(Message m) throws SQLException {
        String sql = "INSERT INTO messages (from_user_id, to_user_id, content) VALUES (?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, m.getFromUserId());
            ps.setInt(2, m.getToUserId());
            ps.setString(3, m.getContent());
            ps.executeUpdate();
        }
    }

    public List<User> getDmPartners(int myId) throws SQLException {
        String sql =
            "SELECT u.*, MAX(m.sent_at) AS last_sent " +
            "FROM messages m " +
            "JOIN users u ON u.user_id = CASE " +
            "   WHEN m.from_user_id = ? THEN m.to_user_id " +
            "   ELSE m.from_user_id END " +
            "WHERE m.from_user_id = ? OR m.to_user_id = ? " +
            "GROUP BY u.user_id, u.username, u.handle, u.password, u.bio, " +
            "         u.profile_image, u.original_image, " +
            "         u.profile_icon_w, u.profile_icon_h, u.profile_icon_x, u.profile_icon_y, " +
            "         u.display_w, u.display_h " +
            "ORDER BY last_sent DESC";

        List<User> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, myId);
            ps.setInt(2, myId);
            ps.setInt(3, myId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setHandle(rs.getString("handle"));
                    u.setPassword(rs.getString("password"));
                    u.setBio(rs.getString("bio"));
                    u.setProfileImage(rs.getString("profile_image"));
                    u.setOriginalImage(rs.getString("original_image"));
                    u.setProfileIconW((Integer) rs.getObject("profile_icon_w"));
                    u.setProfileIconH((Integer) rs.getObject("profile_icon_h"));
                    u.setProfileIconX((Integer) rs.getObject("profile_icon_x"));
                    u.setProfileIconY((Integer) rs.getObject("profile_icon_y"));
                    u.setDisplayWidth((Integer) rs.getObject("display_w"));
                    u.setDisplayHeight((Integer) rs.getObject("display_h"));
                    list.add(u);
                }
            }
        }
        return list;
    }
}