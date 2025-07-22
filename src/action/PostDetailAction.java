package action;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.Comment;
import bean.Post;
import dao.CommentDAO;
import dao.PostDAO;
import tool.Action;

public class PostDetailAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        String tweetIdStr = req.getParameter("tweetId");
        if (tweetIdStr == null) {
            return "redirect:Timeline.action";
        }

        int tweetId;
        try {
            tweetId = Integer.parseInt(tweetIdStr);
        } catch (NumberFormatException e) {
            return "redirect:Timeline.action";
        }

        PostDAO postDao = new PostDAO();
        Post post = postDao.findById(tweetId);
        if (post == null) {
            return "redirect:Timeline.action";
        }

        // ページングパラメータ
        int commentsPerPage = 10;
        int currentPage = 1;
        String commentPageStr = req.getParameter("commentPage");
        if (commentPageStr != null) {
            try {
                currentPage = Integer.parseInt(commentPageStr);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        int offset = (currentPage - 1) * commentsPerPage;

        CommentDAO commentDao = new CommentDAO();
        int totalComments = commentDao.countByTweet(tweetId);
        List<Comment> comments = commentDao.getRootCommentsForTweet(tweetId, offset, commentsPerPage);

        req.setAttribute("post", post);
        req.setAttribute("comments", comments);
        req.setAttribute("totalComments", totalComments);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("commentsPerPage", commentsPerPage);

        return "postdetail.jsp";
    }
}