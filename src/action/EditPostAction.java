package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.Post;
import bean.User;
import dao.PostDAO;
import tool.Action;

public class EditPostAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            return "index.jsp";
        }

        if ("GET".equalsIgnoreCase(req.getMethod())) {
            String idStr = req.getParameter("tweetId");
            if (idStr == null) {
                return "Profile.action";
            }

            int tweetId;
            try {
                tweetId = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                return "Profile.action";
            }

            PostDAO dao = new PostDAO();
            Post post = dao.getPostForEdit(tweetId, me.getUserId());
            if (post == null) {
                // 自分の投稿でない or 存在しない
                return "Profile.action";
            }
            req.setAttribute("post", post);
            return "edit_post.jsp";

        } else if ("POST".equalsIgnoreCase(req.getMethod())) {
            req.setCharacterEncoding("UTF-8");

            String tweetIdStr = req.getParameter("tweetId");
            String content = req.getParameter("content");
            if (tweetIdStr == null || content == null || content.trim().isEmpty()) {
                return "Profile.action";
            }

            int tweetId;
            try {
                tweetId = Integer.parseInt(tweetIdStr);
            } catch (NumberFormatException e) {
                return "Profile.action";
            }

            PostDAO dao = new PostDAO();
            boolean ok = dao.updateContent(tweetId, me.getUserId(), content.trim());

            // 成功失敗問わずプロフィールへ戻る設計
            return "Profile.action";
        }

        // その他のメソッドはトップへ
        return "Timeline.action";
    }
}