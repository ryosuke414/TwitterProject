package action;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import bean.User;
import dao.UserDAO;
import tool.Action;

public class EditProfileAction extends Action {

    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "index.jsp";
        }

        String newUsername = req.getParameter("username");
        String newBio = req.getParameter("bio");

        Integer iconW = parseIntOrNull(req.getParameter("iconWidth"));
        Integer iconH = parseIntOrNull(req.getParameter("iconHeight"));
        Integer iconX = parseIntOrNull(req.getParameter("iconX"));
        Integer iconY = parseIntOrNull(req.getParameter("iconY"));
        Integer displayW = parseIntOrNull(req.getParameter("displayWidth"));
        Integer displayH = parseIntOrNull(req.getParameter("displayHeight"));

        Part imagePart = req.getPart("profileImage");
        String originalFileName = user.getOriginalImage();
        String croppedFileName = user.getProfileImage();

        String uploadBase = req.getServletContext().getRealPath("/profile_images");
        if (uploadBase == null) {
            uploadBase = System.getProperty("java.io.tmpdir") + "/profile_images";
        }
        File originalDir = new File(uploadBase, "original");
        if (!originalDir.exists()) originalDir.mkdirs();

        // 新しい画像アップロードあり
        if (imagePart != null && imagePart.getSize() > 0) {
            String ext = ".jpg";
            originalFileName = "original_u" + user.getUserId() + ext;

            File originalFile = new File(originalDir, originalFileName);
            try (InputStream in = imagePart.getInputStream()) {
                Files.copy(in, originalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
        }

        // クロップ処理
        if (originalFileName != null) {
            File originalFile = new File(originalDir, originalFileName);
            BufferedImage original = ImageIO.read(originalFile);
            if (original != null) {
                int origW = original.getWidth();
                int origH = original.getHeight();

                if (displayW == null || displayW <= 0) displayW = 300;
                if (displayH == null || displayH <= 0) displayH = 300;

                double scaleX = (double) origW / displayW;
                double scaleY = (double) origH / displayH;

                int cropX = (int) Math.round(-iconX * scaleX);
                int cropY = (int) Math.round(-iconY * scaleY);
                int cropW = (int) Math.round(300 * scaleX);
                int cropH = (int) Math.round(300 * scaleY);

                if (cropX < 0) cropX = 0;
                if (cropY < 0) cropY = 0;
                if (cropX + cropW > origW) cropW = origW - cropX;
                if (cropY + cropH > origH) cropH = origH - cropY;

                BufferedImage cropped = original.getSubimage(cropX, cropY, cropW, cropH);
                BufferedImage resized = new BufferedImage(300, 300, BufferedImage.TYPE_INT_RGB);
                Graphics2D g = resized.createGraphics();
                g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
                g.drawImage(cropped, 0, 0, 300, 300, null);
                g.dispose();

                croppedFileName = "cropped_u" + user.getUserId() + ".jpg";
                File croppedFile = new File(uploadBase, croppedFileName);
                ImageIO.write(resized, "jpg", croppedFile);
            }
        }

        // DB更新
        UserDAO udao = new UserDAO();
        udao.updateProfileWithLayout(
            user.getUserId(),
            newUsername,
            newBio,
            croppedFileName,
            iconW, iconH, iconX, iconY,
            displayW, displayH,
            originalFileName
        );

        // セッション更新
        user.setUsername(newUsername);
        user.setBio(newBio);
        user.setProfileImage(croppedFileName);
        user.setOriginalImage(originalFileName);
        user.setProfileIconW(iconW);
        user.setProfileIconH(iconH);
        user.setProfileIconX(iconX);
        user.setProfileIconY(iconY);
        user.setDisplayWidth(displayW);
        user.setDisplayHeight(displayH);

        session.setAttribute("user", user);

        return "Profile.action";
    }

    private Integer parseIntOrNull(String val) {
        if (val == null || val.trim().isEmpty()) return null;
        try {
            return Integer.valueOf(val.trim().replace("px",""));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}