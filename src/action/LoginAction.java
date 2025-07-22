package action;

import java.sql.SQLException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.SearchDAO;
import dao.UserDAO;
import tool.Action;

public class LoginAction extends Action {
    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setCharacterEncoding("UTF-8");

        String handle = req.getParameter("handle");
        String pass = req.getParameter("password");

        try {
            User user = new UserDAO().findByHandleAndPassword(handle, pass);
            if (user != null) {
                // ログイン成功
                req.getSession().setAttribute("user", user);
                // ログイン直後に検索履歴をプリロードしてセッションに保持
                try {
                    List<String> history = new SearchDAO().getHistory(user.getUserId());
                    req.getSession().setAttribute("searchHistory", history);
                } catch (SQLException e) {
                    // 履歴取得失敗してもログイン自体は継続
                    e.printStackTrace();
                }

                // ログイン成功後はタイムラインへリダイレクト
                return "Timeline.action";
            } else {
                // ログイン失敗時はリクエストにエラーをセットしてindex.jspへフォワード
                req.setAttribute("loginError", "ログイン失敗");
                return "index.jsp";
            }
        } catch (SQLException e) {
            throw e;
        }
    }
}