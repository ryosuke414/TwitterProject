package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.Comment;
import bean.User;
import dao.CommentDAO;
import tool.Action;

public class CommentAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.sendRedirect("index.jsp");
            return null;
        }

        String method = req.getMethod();
        if ("POST".equalsIgnoreCase(method)) {
            // --- コメント追加処理 ---

            String tweetIdStr = req.getParameter("tweetId");
            String content = req.getParameter("content");
            String parentCommentIdStr = req.getParameter("parentCommentId");

            if (tweetIdStr == null || content == null || content.trim().isEmpty()) {
                resp.sendRedirect("Timeline.action");
                return null;
            }

            int tweetId;
            try {
                tweetId = Integer.parseInt(tweetIdStr);
            } catch (NumberFormatException e) {
                resp.sendRedirect("Timeline.action");
                return null;
            }

            Integer parentCommentId = null;
            if (parentCommentIdStr != null && !parentCommentIdStr.isEmpty()) {
                try {
                    parentCommentId = Integer.parseInt(parentCommentIdStr);
                } catch (NumberFormatException ignored) {}
            }

            Comment comment = new Comment();
            comment.setTweetId(tweetId);
            comment.setUserId(me.getUserId());
            comment.setContent(content.trim());

            CommentDAO dao = new CommentDAO();
            if (parentCommentId != null) {
                comment.setParentCommentId(parentCommentId);
                dao.insertReply(comment);
            } else {
                dao.insert(comment);
            }

            resp.sendRedirect("PostDetail.action?tweetId=" + tweetId);
            return null;

        } else if ("GET".equalsIgnoreCase(method)) {
            // --- コメント削除処理 ---

            String deleteIdStr = req.getParameter("deleteId");
            String tweetIdStr = req.getParameter("tweetId");
            if (deleteIdStr == null || tweetIdStr == null) {
                resp.sendRedirect("Timeline.action");
                return null;
            }

            int deleteId;
            int tweetId;
            try {
                deleteId = Integer.parseInt(deleteIdStr);
                tweetId = Integer.parseInt(tweetIdStr);
            } catch (NumberFormatException e) {
                resp.sendRedirect("Timeline.action");
                return null;
            }

            CommentDAO dao = new CommentDAO();
            dao.delete(deleteId, me.getUserId());

            resp.sendRedirect("PostDetail.action?tweetId=" + tweetId);
            return null;
        }

        // その他のメソッドは Timeline へリダイレクト
        resp.sendRedirect("Timeline.action");
        return null;
    }
}