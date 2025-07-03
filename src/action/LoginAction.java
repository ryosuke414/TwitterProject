package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.UsersBean;
import dao.LoginDAO;
import tool.Action;

public class LoginAction extends Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        // 入力されたハンドル名とパスワードを取得
        String handle = request.getParameter("handle");
        String password = request.getParameter("password");

        // 入力チェック（未入力など）
        if (handle == null || password == null || handle.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "ハンドル名とパスワードを入力してください。");
            return "login.jsp";
        }

        // DAO を使ってログインチェック
        LoginDAO dao = new LoginDAO();
        UsersBean user = dao.checkLogin(handle, password);

        // ログイン成功
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("loginUser", user);
            	return "home.jsp";

        }
        // ログイン失敗
        request.setAttribute("error", "ログインに失敗しました。ハンドル名またはパスワードが正しくありません。");
        return "login.jsp";
    }
}
