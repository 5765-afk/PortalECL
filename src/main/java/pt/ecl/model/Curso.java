
package pt.ecl.model;

public class Curso {

    private int idCurso;
    private String nome;
    private String modalidade;
    private String nivel;
    private String duracao;
    private String descricao;
    private String perfilSaida;
    private boolean ativo;

    public Curso() {
    }

    public Curso(int idCurso, String nome, String modalidade,
                 String nivel, String duracao, String descricao,
                 String perfilSaida, boolean ativo) {

        this.idCurso = idCurso;
        this.nome = nome;
        this.modalidade = modalidade;
        this.nivel = nivel;
        this.duracao = duracao;
        this.descricao = descricao;
        this.perfilSaida = perfilSaida;
        this.ativo = ativo;
    }

    public int getIdCurso() {
        return idCurso;
    }

    public void setIdCurso(int idCurso) {
        this.idCurso = idCurso;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getModalidade() {
        return modalidade;
    }

    public void setModalidade(String modalidade) {
        this.modalidade = modalidade;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    public String getDuracao() {
        return duracao;
    }

    public void setDuracao(String duracao) {
        this.duracao = duracao;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getPerfilSaida() {
        return perfilSaida;
    }

    public void setPerfilSaida(String perfilSaida) {
        this.perfilSaida = perfilSaida;
    }

    public boolean isAtivo() {
        return ativo;
    }

    public void setAtivo(boolean ativo) {
        this.ativo = ativo;
    }
}
