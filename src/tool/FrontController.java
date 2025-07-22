package tool;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("*.action")
@MultipartConfig  // ← ここを追加
public class FrontController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String uri = request.getRequestURI();           // 例: /TwitterProject/Login.action
        String context = request.getContextPath();       // 例: /TwitterProject
        String actionName = uri.substring(context.length() + 1); // 例: Login.action

        try {
            if (actionName.endsWith(".action")) {
                String className = "action." + actionName.replace(".action", "Action"); // ex: action.LoginAction

                // アクションインスタンス作成
                Class<?> clazz = Class.forName(className);
                Action action = (Action) clazz.newInstance();

                // 実行して画面遷移先取得
                String path = action.execute(request, response);

                if (path != null) {
                    if (path.startsWith("redirect:")) {
                        String redirectPath = path.substring("redirect:".length());
                        response.sendRedirect(redirectPath);
                    } else if (path.endsWith(".action")) {
                        response.sendRedirect(path);
                    } else {
                        RequestDispatcher rd = request.getRequestDispatcher(path);
                        rd.forward(request, response);
                    }
                }
                // path == null の場合は既にレスポンス済みとして何もしない
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}