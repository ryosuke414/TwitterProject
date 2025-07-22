package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.User;
import dao.RepostDAO;
import tool.Action;

public class RepostAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User me = (session != null) ? (User) session.getAttribute("user") : null;

        if (me == null) {
            return "index.jsp";
        }

        String tweetIdStr = req.getParameter("tweetId");
        String op = req.getParameter("op"); // "add" | "remove" | null(=toggle)
        String returnUrl = req.getParameter("returnUrl"); // 任意 hidden で渡す
        int tweetId;

        try {
            tweetId = Integer.parseInt(tweetIdStr);
        } catch (Exception e) {
            return "redirect:Timeline.action";
        }

        RepostDAO dao = new RepostDAO();
        boolean already = dao.isReposted(me.getUserId(), tweetId);

        if (op == null) {
            // トグル
            if (already) dao.removeRepost(me.getUserId(), tweetId);
            else dao.addRepost(me.getUserId(), tweetId);
        } else if ("add".equals(op)) {
            if (!already) dao.addRepost(me.getUserId(), tweetId);
        } else if ("remove".equals(op)) {
            if (already) dao.removeRepost(me.getUserId(), tweetId);
        }

        // 戻り先リダイレクト
        if (returnUrl != null && !returnUrl.trim().isEmpty()) {
            // URLデコードされてない可能性あるので注意（必要ならdecode）
            return "redirect:" + returnUrl;
        } else {
            String referer = req.getHeader("Referer");
            if (referer != null && referer.contains(req.getServerName())) {
                return "redirect:" + referer;
            } else {
                return "redirect:Timeline.action";
            }
        }
    }
}