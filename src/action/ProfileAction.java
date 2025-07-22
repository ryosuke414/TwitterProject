package action;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.Post;
import bean.User;
import dao.FollowDAO;
import dao.PostDAO;
import dao.UserDAO;
import tool.Action;

public class ProfileAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            return "redirect:index.jsp";
        }

        String userIdParam = req.getParameter("userId");
        int targetUserId = (userIdParam == null || userIdParam.isEmpty())
                ? me.getUserId()
                : parseOrFallback(userIdParam, me.getUserId());

        UserDAO udao = new UserDAO();
        FollowDAO fdao = new FollowDAO();
        PostDAO pdao = new PostDAO();

        User target = udao.findById(targetUserId);
        if (target == null) {
            return "redirect:Timeline.action";
        }

        List<Post> posts = pdao.findAllByUserIdIncludingReposts(targetUserId);

        int followingCount = fdao.countFollowing(targetUserId);
        int followerCount  = fdao.countFollowers(targetUserId);
        int postCount      = pdao.countByUserId(targetUserId);

        boolean isFollowing = false;
        if (me.getUserId() != targetUserId) {
            isFollowing = fdao.isFollowing(me.getUserId(), targetUserId);
        }

        req.setAttribute("user", target);
        req.setAttribute("posts", posts);
        req.setAttribute("followingCount", followingCount);
        req.setAttribute("followerCount", followerCount);
        req.setAttribute("postCount", postCount);
        req.setAttribute("isFollowing", isFollowing);

        return "profile.jsp";
    }

    private int parseOrFallback(String s, int fb) {
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return fb;
        }
    }
}