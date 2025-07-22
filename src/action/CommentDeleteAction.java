package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.CommentDAO;
import tool.Action;

public class CommentDeleteAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        HttpSession session = req.getSession(false);
        bean.User me = (session != null) ? (bean.User) session.getAttribute("user") : null;
        if (me == null) {
            resp.sendRedirect("index.jsp");
            return null;
        }

        String commentIdStr = req.getParameter("commentId");
        if (commentIdStr == null) {
            resp.sendRedirect("Timeline.action");
            return null;
        }

        int commentId;
        try {
            commentId = Integer.parseInt(commentIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect("Timeline.action");
            return null;
        }

        CommentDAO dao = new CommentDAO();
        dao.delete(commentId, me.getUserId()); // 自分のコメントのみ削除可能

        // 削除後、元の投稿詳細へリダイレクト
        String tweetId = req.getParameter("tweetId");
        resp.sendRedirect("PostDetail.action?tweetId=" + (tweetId != null ? tweetId : ""));
        return null;
    }
}