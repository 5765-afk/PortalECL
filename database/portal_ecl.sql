
-- =====================================================
-- PORTALECL - SCRIPT COMPLETO MYSQL 8+
-- CORRIGIDO: DUPLICADOS + SAFE UPDATE MODE
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

    CONSTRAINT fk_inscricao_curso
    FOREIGN KEY (id_curso)
    REFERENCES cursos(id_curso)
) ENGINE=InnoDB;

-- =====================================================
-- 4. GARANTIR COLUNA MENSAGEM
-- =====================================================

SET @existe_mensagem = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'pre_inscricoes'
      AND COLUMN_NAME = 'mensagem'
);

SET @sql_mensagem = IF(
    @existe_mensagem = 0,
    'ALTER TABLE pre_inscricoes ADD COLUMN mensagem TEXT NULL',
    'SELECT "Coluna mensagem ja existe"'
);

PREPARE stmt_mensagem FROM @sql_mensagem;
EXECUTE stmt_mensagem;
DEALLOCATE PREPARE stmt_mensagem;

-- =====================================================
-- 5. GARANTIR COLUNA ACEITA_PRIVACIDADE
-- =====================================================

SET @existe_privacidade = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'pre_inscricoes'
      AND COLUMN_NAME = 'aceita_privacidade'
);

SET @sql_privacidade = IF(
    @existe_privacidade = 0,
    'ALTER TABLE pre_inscricoes ADD COLUMN aceita_privacidade BOOLEAN NOT NULL DEFAULT FALSE',
    'SELECT "Coluna aceita_privacidade ja existe"'
);

PREPARE stmt_privacidade FROM @sql_privacidade;
EXECUTE stmt_privacidade;
DEALLOCATE PREPARE stmt_privacidade;

-- =====================================================
-- 6. TABELA AVARIAS
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
-- 7. CORRIGIR CURSOS DUPLICADOS
-- =====================================================

-- Remover tabela temporaria antiga, se existir

DROP TEMPORARY TABLE IF EXISTS mapa_cursos;

-- Criar mapa de cursos com chave primaria

CREATE TEMPORARY TABLE mapa_cursos (
    id_curso INT PRIMARY KEY,
    id_manter INT NOT NULL
) ENGINE=InnoDB;

INSERT INTO mapa_cursos (id_curso, id_manter)
SELECT
    id_curso,
    MIN(id_curso) OVER (
        PARTITION BY nome, modalidade, nivel, duracao
    ) AS id_manter
FROM cursos;

-- Desativar Safe Update Mode apenas nesta sessao
-- para executar a correccao

SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

-- Transferir pre-inscricoes para o curso original

UPDATE pre_inscricoes p
INNER JOIN mapa_cursos m
    ON p.id_curso = m.id_curso
SET p.id_curso = m.id_manter
WHERE m.id_curso <> m.id_manter;

-- Eliminar cursos duplicados

DELETE c
FROM cursos c
INNER JOIN mapa_cursos m
    ON c.id_curso = m.id_curso
WHERE m.id_curso <> m.id_manter;

COMMIT;

-- Reativar Safe Update Mode

SET SQL_SAFE_UPDATES = 1;

-- Eliminar tabela temporaria

DROP TEMPORARY TABLE IF EXISTS mapa_cursos;

-- =====================================================
-- 8. IMPEDIR NOVOS CURSOS DUPLICADOS
-- =====================================================

SET @indice_existe = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cursos'
      AND INDEX_NAME = 'uq_curso_identidade'
);

SET @sql_indice = IF(
    @indice_existe = 0,
    'ALTER TABLE cursos ADD UNIQUE KEY uq_curso_identidade (nome, modalidade, nivel, duracao)',
    'SELECT "Indice de cursos ja existe"'
);

PREPARE stmt_indice FROM @sql_indice;
EXECUTE stmt_indice;
DEALLOCATE PREPARE stmt_indice;

-- =====================================================
-- 9. INSERIR 11 CURSOS
-- =====================================================

INSERT IGNORE INTO cursos (
    nome,
    modalidade,
    nivel,
    duracao,
    descricao,
    perfil_saida,
    ativo
)
VALUES

(
    'Técnico de Informática - Sistemas',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Formação em instalação, configuração e manutenção de sistemas informáticos e redes.',
    'Técnico de informática e administração de sistemas.',
    TRUE
),

(
    'Técnico de Comércio',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Formação na área comercial, vendas e atendimento ao cliente.',
    'Técnico de comércio.',
    TRUE
),

(
    'Técnico de Gestão',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Formação em gestão e organização empresarial.',
    'Técnico de gestão.',
    TRUE
),

(
    'Técnico de Eletrónica',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Instalação, manutenção e reparação de equipamentos eletrónicos.',
    'Técnico de eletrónica.',
    TRUE
),

(
    'Técnico de Marketing',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Marketing digital, publicidade e comunicação empresarial.',
    'Técnico de marketing.',
    TRUE
),

(
    'Técnico de Contabilidade',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Contabilidade, gestão financeira e fiscalidade.',
    'Técnico de contabilidade.',
    TRUE
),

(
    'Técnico de Turismo',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Turismo, organização de viagens e atendimento turístico.',
    'Técnico de turismo.',
    TRUE
),

(
    'Técnico de Multimédia',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Produção audiovisual, edição de imagem e conteúdos digitais.',
    'Técnico de multimédia.',
    TRUE
),

(
    'Técnico de Restaurante e Bar',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Restauração, serviço de bar e atendimento ao cliente.',
    'Técnico de restaurante e bar.',
    TRUE
),

(
    'Técnico de Apoio Psicossocial',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Acompanhamento e apoio psicossocial a pessoas e comunidades.',
    'Técnico de apoio psicossocial.',
    TRUE
),

(
    'Técnico de Logística',
    'Aprendizagem',
    'Nível 4',
    '3 anos',
    'Gestão de stocks, armazenamento e distribuição.',
    'Técnico de logística.',
    TRUE
);

-- =====================================================
-- 10. ADMINISTRADOR INICIAL
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
-- 11. VERIFICAR CURSOS
-- =====================================================

SELECT
    id_curso,
    nome,
    modalidade,
    nivel,
    duracao,
    ativo
FROM cursos
WHERE ativo = TRUE
ORDER BY id_curso;

-- Total de cursos

SELECT COUNT(*) AS total_cursos
FROM cursos
WHERE ativo = TRUE;

-- Verificar duplicados

SELECT
    nome,
    modalidade,
    nivel,
    duracao,
    COUNT(*) AS quantidade
FROM cursos
GROUP BY nome, modalidade, nivel, duracao
HAVING COUNT(*) > 1;

-- =====================================================
-- 12. VERIFICAR PRE-INSCRICOES
-- =====================================================


SELECT
    p.id_inscricao,
    p.nome,
    p.email,
    c.nome AS curso,
    p.estado,
    p.data_inscricao
FROM pre_inscricoes p
INNER JOIN cursos c
    ON p.id_curso = c.id_curso
ORDER BY p.id_inscricao;

-- =====================================================
-- 13. VERIFICAR UTILIZADORES
-- =====================================================

SELECT
    id_utilizador,
    nome,
    email,
    perfil,
    ativo
FROM utilizadores;

-- =====================================================
-- 14. VERIFICAR AVARIAS
-- =====================================================

SELECT * FROM avarias;

-- =====================================================
-- 15. VERIFICAR TABELAS
-- =====================================================

SHOW TABLES;

DESCRIBE cursos;
DESCRIBE utilizadores;
DESCRIBE pre_inscricoes;
DESCRIBE avarias;

SELECT *
FROM pre_inscricoes
ORDER BY id_inscricao;
-- =====================================================
-- FIM DO SCRIPT PORTALECL
-- =====================================================
