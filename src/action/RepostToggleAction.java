package action;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.User;
import dao.RepostDAO;

@WebServlet("/RepostToggle.action")
public class RepostToggleAction extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User me = (User) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect("index.jsp");
            return;
        }

        String tweetIdStr = req.getParameter("tweetId");
        if (tweetIdStr == null) {
            resp.sendRedirect("Timeline.action");
            return;
        }

        int tweetId;
        try {
            tweetId = Integer.parseInt(tweetIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect("Timeline.action");
            return;
        }

        String returnUrl = req.getParameter("returnUrl"); // (任意) 戻り先

        RepostDAO rdao = new RepostDAO();
        try {
            if (rdao.isReposted(me.getUserId(), tweetId)) {
                rdao.removeRepost(me.getUserId(), tweetId);
            } else {
                rdao.addRepost(me.getUserId(), tweetId);
            }

            if (returnUrl != null && returnUrl.trim().length() > 0) {
                resp.sendRedirect(returnUrl);
            } else {
                resp.sendRedirect("Timeline.action");
            }

        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
