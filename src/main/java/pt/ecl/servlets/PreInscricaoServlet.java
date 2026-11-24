package pt.ecl.servlets;

import pt.ecl.config.ConexaoBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/pre-inscricao")
public class PreInscricaoServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String nome=req.getParameter("nome"), email=req.getParameter("email"), telefone=req.getParameter("telefone"), curso=req.getParameter("curso"), mensagem=req.getParameter("mensagem");
        if (vazio(nome)||vazio(email)||vazio(curso)||!email.matches("^[^\s@]+@[^\s@]+\.[^\s@]+$")) { resp.sendRedirect("pre-inscricao.jsp?erro=dados"); return; }
        String sql="INSERT INTO pre_inscricoes(nome,email,telefone,id_curso,mensagem) VALUES(?,?,?,?,?)";
        try (Connection c=ConexaoBD.ligar(); PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setString(1,nome.trim()); ps.setString(2,email.trim()); ps.setString(3,telefone==null?"":telefone.trim()); ps.setInt(4,Integer.parseInt(curso)); ps.setString(5,mensagem==null?"":mensagem.trim()); ps.executeUpdate();
            resp.sendRedirect("pre-inscricao.jsp?sucesso=1");
        } catch (SQLException|NumberFormatException e) { throw new ServletException("Não foi possível registar a pré-inscrição.",e); }
    }
    private boolean vazio(String s){return s==null||s.trim().isEmpty();}
}
