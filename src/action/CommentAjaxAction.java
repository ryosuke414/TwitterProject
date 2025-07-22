package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.Comment;
import bean.User;
import dao.CommentDAO;
import tool.Action;

public class CommentAjaxAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        req.setCharacterEncoding("UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.setStatus(401);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"login required\"}");
            return null;
        }

        String tweetIdStr = req.getParameter("tweetId");
        String content = req.getParameter("content");

        if (tweetIdStr == null || content == null || content.trim().isEmpty()) {
            resp.setStatus(400);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"invalid params\"}");
            return null;
        }

        int tweetId;
        try {
            tweetId = Integer.parseInt(tweetIdStr);
        } catch (NumberFormatException e) {
            resp.setStatus(400);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"invalid id\"}");
            return null;
        }

        Comment c = new Comment();
        c.setTweetId(tweetId);
        c.setUserId(me.getUserId());
        c.setContent(content.trim());

        CommentDAO dao = new CommentDAO();
        try {
            dao.insert(c);
            int newCount = dao.countByTweet(tweetId);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"ok\",\"tweetId\":" + tweetId + ",\"newCount\":" + newCount + "}");
        } catch (Exception e) {
            resp.setStatus(500);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"db error\"}");
        }

        return null;  // JSPへは遷移しない
    }
}