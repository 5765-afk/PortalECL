package pt.ecl.servlets;

import pt.ecl.config.ConexaoBD;
import pt.ecl.util.Seguranca;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8"); String email=req.getParameter("email"), password=req.getParameter("password");
        if(email==null||password==null){resp.sendRedirect("login.jsp?erro=1");return;}
        String sql="SELECT id_utilizador,nome,email,palavra_passe,perfil FROM utilizadores WHERE email=? AND ativo=1";
        try(Connection c=ConexaoBD.ligar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,email.trim());
            try(ResultSet rs=ps.executeQuery()){
                if(rs.next()&&Seguranca.verificar(password,rs.getString("palavra_passe"))){
                    HttpSession old=req.getSession(false);if(old!=null)old.invalidate();
                    HttpSession session=req.getSession(true);session.setAttribute("idUtilizador",rs.getInt("id_utilizador"));session.setAttribute("nomeUtilizador",rs.getString("nome"));session.setAttribute("perfil",rs.getString("perfil"));
                    resp.sendRedirect("gestao");
                }else resp.sendRedirect("login.jsp?erro=1");
            }
        }catch(SQLException e){throw new ServletException("Não foi possível iniciar sessão. Confirma a ligação à base de dados.",e);}
    }
}
