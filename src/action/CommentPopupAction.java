package action;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.Comment;
import bean.Post;
import bean.User;
import dao.CommentDAO;
import dao.LikeDAO;
import dao.PostDAO;
import dao.RepostDAO;
import tool.Action;

public class CommentPopupAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        HttpSession session = req.getSession(false);
        User me = (session != null) ? (User) session.getAttribute("user") : null;
        if (me == null) {
            resp.setStatus(401);
            resp.getWriter().write("ログインが必要です");
            return null; // 直接レスポンス返したのでこれ以上処理しない
        }

        String idStr = req.getParameter("tweetId");
        int tweetId;
        try {
            tweetId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.setStatus(400);
            resp.getWriter().write("不正なID");
            return null;
        }

        PostDAO pdao = new PostDAO();
        CommentDAO cdao = new CommentDAO();
        LikeDAO ldao = new LikeDAO();
        RepostDAO rdao = new RepostDAO();

        Post post = pdao.findById(tweetId);
        if (post == null) {
            resp.setStatus(404);
            resp.getWriter().write("投稿が見つかりません");
            return null;
        }

        List<Comment> comments = cdao.getRootCommentsForTweet(tweetId, 0, 200); // 適宜上限設定
        int likeCount = ldao.countLikes(tweetId);
        int commentCount = cdao.countByTweet(tweetId);
        int repostCount = rdao.countReposts(tweetId);
        boolean liked = ldao.isLiked(me.getUserId(), tweetId);
        boolean reposted = rdao.isReposted(me.getUserId(), tweetId);

        req.setAttribute("post", post);
        req.setAttribute("comments", comments);
        req.setAttribute("likeCount", likeCount);
        req.setAttribute("commentCount", commentCount);
        req.setAttribute("repostCount", repostCount);
        req.setAttribute("liked", liked);
        req.setAttribute("reposted", reposted);

        // フラグメントJSPにforward。前方一致ならフォワードと認識しやすいので "/WEB-INF/..."のパスを返す
        return "/WEB-INF/fragment/comment_popup.jsp";
    }
}