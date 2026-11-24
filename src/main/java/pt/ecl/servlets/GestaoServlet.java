package pt.ecl.servlets;

import pt.ecl.config.ConexaoBD;
import jakarta.servlet.ServletException;import jakarta.servlet.annotation.WebServlet;import jakarta.servlet.http.*;
import java.io.IOException;import java.sql.*;import java.util.*;

@WebServlet("/gestao") public class GestaoServlet extends HttpServlet {
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
  HttpSession s=req.getSession(false);if(s==null||s.getAttribute("idUtilizador")==null){resp.sendRedirect("login.jsp");return;}
  List<Map<String,Object>> avarias=new ArrayList<>();
  try(Connection c=ConexaoBD.ligar();PreparedStatement ps=c.prepareStatement("SELECT id_avaria,nome_reportante,sala,equipamento,descricao,estado,data_registo FROM avarias ORDER BY data_registo DESC");ResultSet rs=ps.executeQuery()){
   while(rs.next()){Map<String,Object> a=new HashMap<>();a.put("id",rs.getInt("id_avaria"));a.put("nome",rs.getString("nome_reportante"));a.put("sala",rs.getString("sala"));a.put("equipamento",rs.getString("equipamento"));a.put("descricao",rs.getString("descricao"));a.put("estado",rs.getString("estado"));a.put("data",rs.getTimestamp("data_registo"));avarias.add(a);}
   req.setAttribute("avarias",avarias);req.getRequestDispatcher("/gestao.jsp").forward(req,resp);
  }catch(SQLException e){throw new ServletException("Erro ao consultar os pedidos de assistência.",e);}
 }
 @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
  HttpSession s=req.getSession(false);if(s==null||s.getAttribute("idUtilizador")==null){resp.sendError(401);return;}
  String estado=req.getParameter("estado"),id=req.getParameter("id");if(!Set.of("Por analisar","Em intervenção","A aguardar","Resolvido").contains(estado)){resp.sendError(400);return;}
  try(Connection c=ConexaoBD.ligar();PreparedStatement ps=c.prepareStatement("UPDATE avarias SET estado=?,id_responsavel=? WHERE id_avaria=?")){
   ps.setString(1,estado);ps.setInt(2,(Integer)s.getAttribute("idUtilizador"));ps.setInt(3,Integer.parseInt(id));ps.executeUpdate();resp.sendRedirect("gestao?atualizado=1");
  }catch(SQLException|NumberFormatException e){throw new ServletException("Não foi possível atualizar o pedido.",e);}
 }
}
