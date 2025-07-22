package action;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.User;
import dao.FollowDAO;
import dao.UserDAO;
import tool.Action;

public class FollowListAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            return "index.jsp";
        }

        String userIdStr = req.getParameter("userId");
        String type = req.getParameter("type");
        if (type == null) type = "following";

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(userIdStr);
        } catch (Exception e) {
            return "Timeline.action";
        }

        UserDAO userDAO = new UserDAO();
        FollowDAO followDAO = new FollowDAO();

        User targetUser = userDAO.findById(targetUserId);
        if (targetUser == null) {
            return "Timeline.action";
        }

        List<User> list = "followers".equals(type)
                ? userDAO.findFollowerUsers(targetUserId)
                : userDAO.findFollowingUsers(targetUserId);

        Set<Integer> myFollowingIdSet = new HashSet<>(followDAO.getFollowingIds(me.getUserId()));

        req.setAttribute("targetUser", targetUser);
        req.setAttribute("list", list);
        req.setAttribute("type", type);
        req.setAttribute("me", me);
        req.setAttribute("myFollowingIds", myFollowingIdSet);

        // フォワード先 JSP のパスを返す（FrontControllerでforwardされる）
        return "/follow_list.jsp";
    }
}