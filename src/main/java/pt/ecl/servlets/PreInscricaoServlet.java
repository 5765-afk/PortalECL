
package pt.ecl.servlets;

import pt.ecl.config.ConexaoBD;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/pre-inscricao")
public class PreInscricaoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // Receber os dados do formulário
        String nome = req.getParameter("nome");
        String email = req.getParameter("email");
        String telefone = req.getParameter("telefone");
        String curso = req.getParameter("curso");
        String mensagem = req.getParameter("mensagem");

        // Receber a aceitação da política de privacidade
        String privacidade = req.getParameter("aceita_privacidade");

        // Validar os dados obrigatórios
        if (vazio(nome) || vazio(email) || vazio(curso)
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {

            resp.sendRedirect("pre-inscricao.jsp?erro=dados");
            return;
        }

        // Validar a aceitação da política de privacidade
        if (!"true".equalsIgnoreCase(privacidade)) {

            resp.sendRedirect("pre-inscricao.jsp?erro=privacidade");
            return;
        }

        // Comando SQL atualizado com aceita_privacidade
        String sql = "INSERT INTO pre_inscricoes "
                + "(nome, email, telefone, id_curso, mensagem, aceita_privacidade) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection c = ConexaoBD.ligar();
             PreparedStatement ps = c.prepareStatement(sql)) {

            // Preencher os parâmetros do INSERT
            ps.setString(1, nome.trim());
            ps.setString(2, email.trim());
            ps.setString(3, telefone == null ? "" : telefone.trim());
            ps.setInt(4, Integer.parseInt(curso));
            ps.setString(5, mensagem == null ? "" : mensagem.trim());

            // Guardar a aceitação da política de privacidade
            ps.setBoolean(6, true);

            // Executar a inserção na base de dados
            ps.executeUpdate();

            // Redirecionar após o registo bem-sucedido
            resp.sendRedirect("pre-inscricao.jsp?sucesso=1");

        } catch (SQLException | NumberFormatException e) {

            throw new ServletException(
                    "Não foi possível registar a pré-inscrição.", e);
        }
    }

    // Verificar se um campo está vazio
    private boolean vazio(String s) {
        return s == null || s.trim().isEmpty();
    }
}
