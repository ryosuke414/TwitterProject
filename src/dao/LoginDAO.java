package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import bean.UsersBean;

public class LoginDAO extends TwitterDAO {
    public UsersBean checkLogin(String handle, String password) throws Exception {
        UsersBean user = null;
        try (Connection con = getConnection();
             PreparedStatement st = con.prepareStatement(
                 "SELECT username, handle, email, password, bio, profile_image, is_active FROM users WHERE handle = ? AND password = ?")) {
            st.setString(1, handle);
            st.setString(2, password);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    user = new UsersBean(
                    	rs.getString("username"),
                        rs.getString("handle"),
                        rs.getString("email"),
                        rs.getString("bio"),
                        rs.getString("profile_image"),
                        rs.getBoolean("is_active")


                    );
                }
            }
        }
        return user;
    }
}