package pt.ecl.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Centraliza a ligação à base de dados. As credenciais podem ser definidas por variáveis de ambiente. */
public final class ConexaoBD {
    private static final String URL = System.getenv().getOrDefault("PORTALECL_DB_URL",
            "jdbc:mysql://localhost:3306/portal_ecl?useSSL=false&serverTimezone=Europe/Lisbon&allowPublicKeyRetrieval=true");
    private static final String UTILIZADOR = System.getenv().getOrDefault("PORTALECL_DB_USER", "root");
    private static final String PASSWORD = System.getenv().getOrDefault("PORTALECL_DB_PASSWORD", "");

    private ConexaoBD() { }

    public static Connection ligar() throws SQLException {
        return DriverManager.getConnection(URL, UTILIZADOR, PASSWORD);
    }
}
