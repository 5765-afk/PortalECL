package pt.ecl.servlets;

import pt.ecl.config.ConexaoBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/reportar-avaria")
public class AvariaServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        String nome=req.getParameter("nome"), email=req.getParameter("email"), sala=req.getParameter("sala"), descricao=req.getParameter("descricao"), equipamento=req.getParameter("equipamento");
        if (vazio(nome)||vazio(sala)||vazio(descricao)||descricao.trim().length()<10) {resp.sendRedirect("reportar-avaria.jsp?erro=dados");return;}
        String sql="INSERT INTO avarias(nome_reportante,email,sala,equipamento,descricao) VALUES(?,?,?,?,?)";
        try(Connection c=ConexaoBD.ligar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,nome.trim());ps.setString(2,email==null?"":email.trim());ps.setString(3,sala.trim());ps.setString(4,equipamento==null?"":equipamento.trim());ps.setString(5,descricao.trim());ps.executeUpdate();resp.sendRedirect("reportar-avaria.jsp?sucesso=1");
        }catch(SQLException e){throw new ServletException("Não foi possível registar a avaria.",e);}
    }
    private boolean vazio(String s){return s==null||s.trim().isEmpty();}
}
