
package pt.ecl.servlets;

import pt.ecl.dao.CursoDAO;
import pt.ecl.model.Curso;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/cursos")
public class CursoServlet extends HttpServlet {

    private final CursoDAO cursoDAO = new CursoDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Curso> cursos = cursoDAO.listarCursos();

            request.setAttribute("cursos", cursos);

            request.getRequestDispatcher("/cursos.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Erro ao consultar os cursos.", e);
        }
    }
}
