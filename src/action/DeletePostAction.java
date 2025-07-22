package action;

import java.io.File;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.User;
import dao.PostDAO;
import tool.Action;

public class DeletePostAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        HttpSession session = req.getSession(false);
        User me = (session != null) ? (User) session.getAttribute("user") : null;
        if (me == null) {
            // ログインしていなければトップにリダイレクト
            return "redirect:index.jsp";
        }

        String tweetIdStr = req.getParameter("tweetId");
        if (tweetIdStr == null || tweetIdStr.isEmpty()) {
            // パラメータ不正ならプロフィールへ戻す
            return "redirect:Profile.action";
        }

        int tweetId;
        try {
            tweetId = Integer.parseInt(tweetIdStr);
        } catch (NumberFormatException e) {
            return "redirect:Profile.action";
        }

        PostDAO dao = new PostDAO();

        try {
            // 削除対象投稿の画像ファイル名を取得
            List<String> files = dao.getImageFileNames(tweetId);

            // 投稿削除（本人投稿のみ）
            boolean ok = dao.deletePost(tweetId, me.getUserId());

            // 投稿削除成功＆画像ファイルあれば物理削除
            if (ok && files != null && !files.isEmpty()) {
                String base = req.getServletContext().getRealPath("/images");
                if (base != null) {
                    for (String f : files) {
                        File file = new File(base, f);
                        if (file.exists()) {
                            file.delete();
                        }
                    }
                }
            }

            // プロフィールページへ戻す
            return "redirect:Profile.action";

        } catch (SQLException e) {
            throw e; // 上位で処理（FrontController等）
        }
    }
}