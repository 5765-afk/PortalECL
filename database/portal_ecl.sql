
-- =====================================================
-- PORTALECL - BASE DE DADOS MYSQL 8+
-- SCRIPT COMPLETO ATUALIZADO E CORRIGIDO
-- =====================================================

CREATE DATABASE IF NOT EXISTS portal_ecl
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE portal_ecl;

-- =====================================================
-- 1. TABELA CURSOS
-- =====================================================

CREATE TABLE IF NOT EXISTS cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    modalidade VARCHAR(80) NOT NULL,
    nivel VARCHAR(80) NOT NULL,
    duracao VARCHAR(80) NOT NULL,
    descricao TEXT,
    perfil_saida TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- 2. TABELA UTILIZADORES
-- =====================================================

CREATE TABLE IF NOT EXISTS utilizadores (
    id_utilizador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    palavra_passe VARCHAR(255) NOT NULL,
    perfil ENUM('ADMIN','TECNICO')
        NOT NULL DEFAULT 'TECNICO',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- CORRECAO DA COLUNA PERFIL

ALTER TABLE utilizadores
MODIFY COLUMN perfil ENUM('ADMIN','TECNICO')
NOT NULL DEFAULT 'TECNICO';

-- =====================================================
-- 3. TABELA PRE-INSCRICOES
-- =====================================================

CREATE TABLE IF NOT EXISTS pre_inscricoes (
    id_pre_inscricao INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telefone VARCHAR(30),
    id_curso INT NOT NULL,
    mensagem TEXT,
    aceita_privacidade BOOLEAN NOT NULL DEFAULT FALSE,
    estado ENUM(
        'Recebida',
        'Em análise',
        'Contactado',
        'Concluída'
    ) NOT NULL DEFAULT 'Recebida',
    data_registo TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_preinscricao_curso
    FOREIGN KEY (id_curso)
    REFERENCES cursos(id_curso)
) ENGINE=InnoDB;

-- GARANTIR QUE A COLUNA MENSAGEM EXISTE

SET @coluna_mensagem_existe = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'pre_inscricoes'
      AND COLUMN_NAME = 'mensagem'
);

SET @sql_mensagem = IF(
    @coluna_mensagem_existe = 0,
    'ALTER TABLE pre_inscricoes ADD COLUMN mensagem TEXT NULL',
    'SELECT "A coluna mensagem ja existe" AS resultado'
);

PREPARE stmt_mensagem FROM @sql_mensagem;
EXECUTE stmt_mensagem;
DEALLOCATE PREPARE stmt_mensagem;

-- GARANTIR QUE A COLUNA ACEITA_PRIVACIDADE EXISTE

SET @coluna_privacidade_existe = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'pre_inscricoes'
      AND COLUMN_NAME = 'aceita_privacidade'
);

SET @sql_privacidade = IF(
    @coluna_privacidade_existe = 0,
    'ALTER TABLE pre_inscricoes
     ADD COLUMN aceita_privacidade BOOLEAN NOT NULL DEFAULT FALSE',
    'SELECT "A coluna aceita_privacidade ja existe" AS resultado'
);

PREPARE stmt_privacidade FROM @sql_privacidade;
EXECUTE stmt_privacidade;
DEALLOCATE PREPARE stmt_privacidade;

-- =====================================================
-- 4. TABELA AVARIAS
-- =====================================================

CREATE TABLE IF NOT EXISTS avarias (
    id_avaria INT AUTO_INCREMENT PRIMARY KEY,
    nome_reportante VARCHAR(120) NOT NULL,
    email VARCHAR(150),
    sala VARCHAR(100) NOT NULL,
    equipamento VARCHAR(120),
    descricao TEXT NOT NULL,
    estado ENUM(
        'Por analisar',
        'Em intervenção',
        'A aguardar',
        'Resolvido'
    ) NOT NULL DEFAULT 'Por analisar',
    id_responsavel INT NULL,
    data_registo TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_avaria_responsavel
    FOREIGN KEY (id_responsavel)
    REFERENCES utilizadores(id_utilizador)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================
-- 5. CURSO DE DEMONSTRACAO
-- =====================================================

INSERT INTO cursos (
    nome,
    modalidade,
    nivel,
    duracao,
    descricao,
    perfil_saida
)
SELECT
    'Técnico de Informática - Sistemas',
    'Curso de Aprendizagem',
    'Nível 4',
    '3 anos',
    'Formação na instalação, configuração e manutenção de sistemas informáticos e redes.',
    'Técnico de informática, apoio ao utilizador e administração de sistemas.'
WHERE NOT EXISTS (
    SELECT 1 FROM cursos
);

-- =====================================================
-- 6. ADMINISTRADOR INICIAL
-- =====================================================

INSERT INTO utilizadores (
    nome,
    email,
    palavra_passe,
    perfil
)
SELECT
    'Administrador PortalECL',
    'admin@portalecl.local',
    'pbkdf2$210000$MDEyMzQ1Njc4OWFiY2RlZg==$oXZ9vYxDi7dY79wwreT6VoquXV3PXJhHHuVQuM6Piec=',
    'ADMIN'
WHERE NOT EXISTS (
    SELECT 1
    FROM utilizadores
    WHERE email = 'admin@portalecl.local'
);

-- =====================================================
-- 7. VERIFICACAO FINAL
-- =====================================================

SHOW TABLES;

DESCRIBE pre_inscricoes;

DESCRIBE utilizadores;

SELECT * FROM cursos;

SELECT
    id_utilizador,
    nome,
    email,
    perfil,
    ativo
FROM utilizadores;

SELECT * FROM pre_inscricoes;

SELECT * FROM avarias;

-- =====================================================
-- FIM DO SCRIPT PORTALECL
-- =====================================================
