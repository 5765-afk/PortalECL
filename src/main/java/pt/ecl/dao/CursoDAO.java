
package pt.ecl.dao;

import pt.ecl.config.ConexaoBD;
import pt.ecl.model.Curso;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CursoDAO {

    public List<Curso> listarCursos() throws SQLException {

        List<Curso> cursos = new ArrayList<>();

        String sql = "SELECT * FROM cursos WHERE ativo = TRUE";

        try (Connection conexao = ConexaoBD.ligar();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet resultado = stmt.executeQuery()) {

            while (resultado.next()) {

                Curso curso = new Curso();

                curso.setIdCurso(resultado.getInt("id_curso"));
                curso.setNome(resultado.getString("nome"));
                curso.setModalidade(resultado.getString("modalidade"));
                curso.setNivel(resultado.getString("nivel"));
                curso.setDuracao(resultado.getString("duracao"));
                curso.setDescricao(resultado.getString("descricao"));
                curso.setPerfilSaida(resultado.getString("perfil_saida"));
                curso.setAtivo(resultado.getBoolean("ativo"));

                cursos.add(curso);
            }
        }

        return cursos;
    }
}
