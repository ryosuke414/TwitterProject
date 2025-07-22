package action;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.Message;
import bean.User;
import dao.MessageDAO;
import dao.UserDAO;

@WebServlet("/DM.action")
public class DMAction extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        User me = (User) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect("index.jsp");
            return;
        }

        MessageDAO mdao = new MessageDAO();
        UserDAO    udao = new UserDAO();

        // 選択中 DM 相手 ID
        Integer toId = null;
        String toStr = req.getParameter("to");
        if (toStr != null && !toStr.isEmpty()) {
            try {
                toId = Integer.parseInt(toStr);
            } catch (NumberFormatException ignore) {}
        }

        User partner = null;
        List<Message> conversation = null;

        try {
            // 左中央：これまで DM した相手一覧
            List<User> partners = mdao.getDmPartners(me.getUserId());

            // 新しいDMモーダル用：全ユーザー（自分を除外）
            List<User> allUsers = udao.getAllExcept(me.getUserId());
            req.setAttribute("allUsers", allUsers);

            // 右側チャット：選択中の相手があれば会話を取得
            if (toId != null) {
                partner = udao.findById(toId);
                if (partner != null) {
                    conversation = mdao.getConversation(me.getUserId(), toId);

                    // final変数に代入してラムダで使う
                    final User finalPartner = partner;

                    // partnersに含まれていない場合、先頭に追加
                    boolean exists = partners.stream()
                        .anyMatch(u -> u.getUserId() == finalPartner.getUserId());

                    if (!exists) {
                        partners.add(0, partner);
                    }
                }
            }

            req.setAttribute("partners", partners);
            req.setAttribute("partner", partner);
            req.setAttribute("messages", conversation);
            req.setAttribute("toId", toId);

            RequestDispatcher rd = req.getRequestDispatcher("dm.jsp");
            rd.forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }

    }

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

        String toIdStr = req.getParameter("toId");
        String content = req.getParameter("content");
        if (toIdStr == null || content == null || content.trim().isEmpty()) {
            // 相手未指定 or 空送信 → 一覧へ戻す
            resp.sendRedirect("DM.action");
            return;
        }

        int toId;
        try {
            toId = Integer.parseInt(toIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect("DM.action");
            return;
        }

        Message msg = new Message();
        msg.setFromUserId(me.getUserId());
        msg.setToUserId(toId);
        msg.setContent(content.trim());

        MessageDAO mdao = new MessageDAO();
        try {
            mdao.sendMessage(msg);
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        // 再表示（右側チャット更新）
        resp.sendRedirect("DM.action?to=" + toId);
    }
}