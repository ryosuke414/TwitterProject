package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.BookmarkDAO;
import tool.Action;

public class BookmarkAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // ログインチェック
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect("index.jsp");
            return null;  // リダイレクト済みなので戻り値なし
        }

        int tweetId = Integer.parseInt(req.getParameter("tweetId"));
        String op = req.getParameter("op"); // add / remove
        String redirect = req.getParameter("redirect"); // 任意のリダイレクト先

        BookmarkDAO dao = new BookmarkDAO();
        if ("add".equals(op)) {
            dao.addBookmark(user.getUserId(), tweetId);
        } else if ("remove".equals(op)) {
            dao.removeBookmark(user.getUserId(), tweetId);
        }

        if (redirect != null && !redirect.isEmpty()) {
            resp.sendRedirect(redirect);
        } else {
            resp.sendRedirect("Timeline.action");
        }
        return null;
    }
}