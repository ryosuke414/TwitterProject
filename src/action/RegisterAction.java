package action;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import dao.UserDAO;
import tool.Action;

@MultipartConfig
public class RegisterAction extends Action {

    private String getValueFromPart(Part part) throws IOException {
        if (part == null) return null;
        try (BufferedReader reader = new BufferedReader(
                 new InputStreamReader(part.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder value = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                value.append(line);
            }
            return value.toString();
        }
    }

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // MultipartFormでは request.getParameter() は使えないため、Partから値を読み取る
        String username = getValueFromPart(request.getPart("username"));
        String handle = getValueFromPart(request.getPart("handle"));
        String password = getValueFromPart(request.getPart("password"));
        String bio = getValueFromPart(request.getPart("bio"));

        Part part = request.getPart("profileImage");
        String fileName = null;

        if (part != null && part.getSize() > 0) {
            fileName = System.currentTimeMillis() + "_" + part.getSubmittedFileName();
            String uploadDir = request.getServletContext().getRealPath("/uploads");
            new java.io.File(uploadDir).mkdirs();
            part.write(uploadDir + java.io.File.separator + fileName);
        }

        // 必須項目チェック
        if (username == null || username.isEmpty() ||
            handle == null || handle.isEmpty() ||
            password == null || password.isEmpty()) {
            request.setAttribute("registerError", "必須項目が入力されていません。");
            return "index.jsp";
        }

        try {
            UserDAO dao = new UserDAO();
            dao.insertUser(username, handle, password, bio, fileName);
            return "redirect:index.jsp?registered=1";

        } catch (SQLException e) {
            request.setAttribute("registerError", "登録に失敗しました（ハンドル重複など）");
            return "index.jsp";
        }
    }
}