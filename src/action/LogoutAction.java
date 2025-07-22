package action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import tool.Action;

public class LogoutAction extends Action {
    @Override
    public String execute(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.getSession().invalidate();
        return "redirect:index.jsp";
    }
}