package action;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.Post;
import bean.User;
import dao.BookmarkDAO;
import dao.PostDAO;
import tool.Action;

public class BookmarkListAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.sendRedirect("index.jsp");
            return null;
        }

        BookmarkDAO bdao = new BookmarkDAO();
        PostDAO pdao = new PostDAO();

        List<Integer> ids = bdao.getBookmarkedTweetIds(me.getUserId());
        List<Post> posts = new ArrayList<>();
        for (Integer id : ids) {
            Post p = pdao.findById(id);
            if (p != null) posts.add(p);
        }

        // 新しい順にソート
        posts.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));

        req.setAttribute("posts", posts);
        // フォワード先はJSPファイル名だけを返す
        return "bookmark.jsp";
    }
}