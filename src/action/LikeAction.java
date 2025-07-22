package action;

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.LikeDAO;
import tool.Action;

public class LikeAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // ログインチェック
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            // ログインしていなければトップページへリダイレクト
            return "index.jsp";
        }

        int tweetId;
        try {
            tweetId = Integer.parseInt(req.getParameter("tweetId"));
        } catch (NumberFormatException e) {
            // 不正なtweetIdの場合はタイムラインへ戻す
            return "Timeline.action";
        }

        try {
            LikeDAO dao = new LikeDAO();
            dao.toggleLike(me.getUserId(), tweetId);
        } catch (SQLException e) {
            throw e;
        }

        // いいね処理後はタイムラインへリダイレクト
        return "Timeline.action";
    }
}