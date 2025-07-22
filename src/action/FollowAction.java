package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.FollowDAO;
import tool.Action;

public class FollowAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            return "index.jsp";
        }

        String targetIdStr = req.getParameter("targetId");
        if (targetIdStr == null) {
            return "Timeline.action";
        }

        try {
            int targetId = Integer.parseInt(targetIdStr);
            if (targetId != me.getUserId()) {
                FollowDAO dao = new FollowDAO();
                dao.follow(me.getUserId(), targetId);
            }
            return "Profile.action?userId=" + targetId;
        } catch (NumberFormatException e) {
            return "Timeline.action";
        }
    }
}