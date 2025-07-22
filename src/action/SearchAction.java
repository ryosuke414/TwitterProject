package action;

import java.net.URLEncoder;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.Post;
import bean.User;
import dao.FollowDAO;
import dao.SearchDAO;
import tool.Action;

public class SearchAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User me = (User) session.getAttribute("user");
        if (me == null) {
            return "index.jsp";
        }

        // EL から参照できるように
        req.setAttribute("me", me);

        String method = req.getMethod();

        if ("GET".equalsIgnoreCase(method)) {
            String keyword = req.getParameter("keyword");
            SearchDAO searchDao = new SearchDAO();

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.trim();

                List<Post> postResult = searchDao.searchPosts(kw);
                req.setAttribute("postResult", postResult);

                List<User> userResult = searchDao.searchUsers(kw);
                // 自分自身は結果から除外
                userResult.removeIf(u -> u.getUserId() == me.getUserId());
                req.setAttribute("userResult", userResult);

                // 履歴保存
                searchDao.saveHistory(me.getUserId(), kw);
            }

            // 最新履歴取得
            SearchDAO search = new SearchDAO();
            List<String> history = search.getHistory(me.getUserId());
            req.setAttribute("history", history);
            session.setAttribute("searchHistory", history);

            FollowDAO fdao = new FollowDAO();
            Set<Integer> followingIds = fdao.findFollowingIdSet(me.getUserId());
            req.setAttribute("followingIds", followingIds);

            // フォワード先
            return "search.jsp";

        } else if ("POST".equalsIgnoreCase(method)) {
            String op = req.getParameter("op");
            String keyword = req.getParameter("keyword");

            SearchDAO dao = new SearchDAO();
            if ("clearHistory".equals(op)) {
                dao.clearHistory(me.getUserId());
            } else if ("deleteOne".equals(op) && keyword != null && !keyword.isEmpty()) {
                dao.deleteHistory(me.getUserId(), keyword);
            }

            // 更新後の履歴を取得して session に反映
            List<String> history = dao.getHistory(me.getUserId());
            session.setAttribute("searchHistory", history);

            // リダイレクト先
            if (keyword != null && !keyword.isEmpty() && !"clearHistory".equals(op)) {
                return "redirect:Search.action?keyword=" + URLEncoder.encode(keyword, "UTF-8");
            } else {
                return "redirect:Search.action";
            }
        }

        // メソッド未対応の場合はindexに戻す
        return "index.jsp";
    }
}