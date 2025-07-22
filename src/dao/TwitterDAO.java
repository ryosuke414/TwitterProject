package dao;

import java.sql.Connection;
import java.sql.SQLException;

import javax.naming.InitialContext;
import javax.sql.DataSource;

public class TwitterDAO {
    static DataSource ds;

    public Connection getConnection() throws SQLException {
        try {
            if (ds == null) {
                InitialContext ic = new InitialContext();
                ds = (DataSource) ic.lookup("java:/comp/env/jdbc/twitter");
            }
            return ds.getConnection();
        } catch (Exception e) {
            throw new SQLException("データソースの取得に失敗しました", e);
        }
    }
}