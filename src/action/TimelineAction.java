package action;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.PostDAO;
import dao.SearchDAO;
import tool.Action;

public class TimelineAction extends Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        User me = (User) request.getSession().getAttribute("user");

        if (me == null) {
            // ログインしていなければログイン画面へ
            return "index.jsp";
        }

        try {
            // タイムライン投稿を取得しリクエストにセット
            request.setAttribute("posts", new PostDAO().getTimeline(me.getUserId()));
        } catch (Exception e) {
            throw new Exception(e);
        }

        // 検索履歴を request にセット（right_sidebar.jsp 用）
        @SuppressWarnings("unchecked")
        List<String> hist = (List<String>) request.getSession().getAttribute("searchHistory");
        if (hist == null) {
            try {
                hist = new SearchDAO().getHistory(me.getUserId());
                request.getSession().setAttribute("searchHistory", hist);
            } catch (Exception e) {
                throw new Exception(e);
            }
        }
        request.setAttribute("history", hist);

        // 表示用JSPへフォワード
        return "home.jsp";
    }
}