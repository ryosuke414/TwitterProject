package action;

import java.sql.SQLException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.UserDAO;
import tool.Action;

public class UserListAction extends Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        User me = (User) request.getSession().getAttribute("user");
        if (me == null) {
            // ログインしてなければログイン画面へリダイレクト
            return "index.jsp";
        }

        try {
            List<User> users = new UserDAO().getAllExcept(me.getUserId());
            request.setAttribute("users", users);
            return "userlist.jsp";  // フォワード先JSP
        } catch (SQLException e) {
            throw e;
        }
    }
}