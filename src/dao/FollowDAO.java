package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FollowDAO extends TwitterDAO {

    public void follow(int followerId, int followedId) throws SQLException {
        if (followerId == followedId) return;
        if (isFollowing(followerId, followedId)) return;

        String sql = "INSERT INTO followers (follower_user_id, followed_user_id) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followedId);
            ps.executeUpdate();
        }
    }

    public void unfollow(int followerId, int followedId) throws SQLException {
        String sql = "DELETE FROM followers WHERE follower_user_id = ? AND followed_user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followedId);
            ps.executeUpdate();
        }
    }

    public boolean isFollowing(int followerId, int followedId) throws SQLException {
        String sql = "SELECT 1 FROM followers WHERE follower_user_id = ? AND followed_user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followedId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<Integer> getFollowingIds(int userId) throws SQLException {
        String sql = "SELECT followed_user_id FROM followers WHERE follower_user_id = ?";
        List<Integer> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("followed_user_id"));
                }
            }
        }
        return list;
    }

    public int countFollowing(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM followers WHERE follower_user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countFollowers(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM followers WHERE followed_user_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public Set<Integer> findFollowingIdSet(int userId) throws SQLException {
        String sql = "SELECT followed_user_id FROM followers WHERE follower_user_id = ?";
        Set<Integer> set = new HashSet<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getInt("followed_user_id"));
                }
            }
        }
        return set;
    }
}