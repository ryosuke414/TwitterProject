package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.FollowDAO;
import tool.Action;

public class UnfollowAction extends Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        User me = (User) request.getSession().getAttribute("user");
        if (me == null) {
            // ログインしていなければログインページへ
            return "index.jsp";
        }

        String targetIdStr = request.getParameter("targetId");
        if (targetIdStr == null) {
            // パラメータなければタイムラインへリダイレクト
            return "Timeline.action";
        }

        try {
            int targetId = Integer.parseInt(targetIdStr);
            if (targetId != me.getUserId()) {
                FollowDAO dao = new FollowDAO();
                dao.unfollow(me.getUserId(), targetId);
            }
            // プロフィールページへリダイレクト
            return "Profile.action?userId=" + targetId;
        } catch (NumberFormatException e) {
            throw new Exception("不正なユーザーID", e);
        }
    }
}