package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * コメント取得など重い処理を行う既存 CommentDAO とは分離し、
 * 件数など軽量クエリ専用にした DAO。
 */
public class CommenticonDAO extends TwitterDAO {

    /** あるツイートに紐づく（親子含む）コメント総数を返す */
    public int countComments(int tweetId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM comments WHERE tweet_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tweetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * 複数 tweetId に対する一括件数取得（オプション）。
     * 戻りを Map<Integer, Integer> にしたい場合などは必要に応じて拡張。
     */
    /*
    public Map<Integer, Integer> countCommentsBulk(List<Integer> tweetIds) throws SQLException {
        Map<Integer, Integer> map = new HashMap<>();
        if (tweetIds == null || tweetIds.isEmpty()) return map;

        // IN 句を動的生成
        StringBuilder sb = new StringBuilder("SELECT tweet_id, COUNT(*) c FROM comments WHERE tweet_id IN (");
        for (int i = 0; i < tweetIds.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append('?');
        }
        sb.append(") GROUP BY tweet_id");

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {

            int idx = 1;
            for (Integer id : tweetIds) ps.setInt(idx++, id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("tweet_id"), rs.getInt("c"));
                }
            }
        }
        return map;
    }
    */
}