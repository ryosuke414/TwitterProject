package action;

import java.io.File;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import bean.User;
import dao.PostDAO;
import tool.Action;

public class PostAction extends Action {

    private static final String UPLOAD_DIR = "images";   // WebContent/images/

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setCharacterEncoding("UTF-8");

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            System.out.println("PostAction: User not logged in");
            return "redirect:index.jsp";
        }

        String content = req.getParameter("content");
        String redirectUrl = req.getParameter("redirect");

        System.out.println("PostAction: user_id=" + user.getUserId() + ", content=" + content);

        PostDAO dao = new PostDAO();
        int tweetId;
        try {
            tweetId = dao.insert(user.getUserId(), content);
            System.out.println("PostAction: Tweet inserted, tweet_id=" + tweetId);
        } catch (SQLException e) {
            System.out.println("PostAction: Failed to insert tweet");
            e.printStackTrace();
            throw e;
        }

        // 画像アップロード処理
        String appPath = req.getServletContext().getRealPath("/");
        File imgDir = new File(appPath, UPLOAD_DIR);
        if (!imgDir.exists()) {
            imgDir.mkdir();
            System.out.println("PostAction: Created image directory: " + imgDir.getAbsolutePath());
        }

        try {
            for (Part part : req.getParts()) {
                if ("images".equals(part.getName()) && part.getSize() > 0) {
                    String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    String unique = UUID.randomUUID() + "_" + original;
                    File savedFile = new File(imgDir, unique);
                    part.write(savedFile.getAbsolutePath());
                    dao.saveImage(tweetId, unique);
                    System.out.println("PostAction: Image saved: " + unique);
                }
            }
        } catch (SQLException e) {
            System.out.println("PostAction: Failed to save image");
            e.printStackTrace();
            throw e;
        }

        // リダイレクト処理
        if (redirectUrl != null && !redirectUrl.isEmpty()) {
            System.out.println("PostAction: Redirecting to " + redirectUrl);
            return "redirect:" + redirectUrl;
        } else {
            System.out.println("PostAction: Redirecting to Timeline.action");
            return "redirect:Timeline.action";
        }
    }
}