-- =====================================================
-- PROJECTO: SISTEMA DE GESTAO DE CONSULTAS MEDICAS
-- LOCALIZACAO: CHIMOIO - MANICA
-- SGBD: MYSQL (compativel com MySQL Workbench e Railway)
--
-- COMO USAR:
--   1. No MySQL Workbench, ligar-se a base de dados do Railway
--      (host e porta do MYSQL_PUBLIC_URL, utilizador root).
--   2. File > Open SQL Script e escolher este ficheiro.
--   3. Clicar no raio (Execute) para correr tudo.
--
-- Este script pode ser executado varias vezes: apaga e
-- recria as tabelas do projecto sempre que corre.
-- =====================================================


-- =====================================================
-- 1. CRIAR A BASE DE DADOS
-- =====================================================

CREATE DATABASE IF NOT EXISTS gestao_consultas
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gestao_consultas;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS medico;
DROP TABLE IF EXISTS especialidade;
DROP TABLE IF EXISTS paciente;

SET FOREIGN_KEY_CHECKS = 1;


-- =====================================================
-- 2. CRIAR AS TABELAS
-- =====================================================

-- TABELA 1: PACIENTE

CREATE TABLE paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sexo ENUM('Masculino', 'Feminino') NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(20) NOT NULL,
    endereco VARCHAR(150)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- TABELA 2: ESPECIALIDADE

CREATE TABLE especialidade (
    id_especialidade INT AUTO_INCREMENT PRIMARY KEY,
    nome_especialidade VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- TABELA 3: MEDICO

CREATE TABLE medico (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    estado ENUM('Activo', 'Inactivo')
        NOT NULL DEFAULT 'Activo',
    id_especialidade INT NOT NULL,

    CONSTRAINT fk_medico_especialidade
    FOREIGN KEY (id_especialidade)
    REFERENCES especialidade(id_especialidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- TABELA 4: CONSULTA

CREATE TABLE consulta (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    data_consulta DATE NOT NULL,
    hora_consulta TIME NOT NULL,
    motivo VARCHAR(255),
    estado ENUM('Marcada', 'Realizada', 'Cancelada')
        NOT NULL DEFAULT 'Marcada',

    CONSTRAINT fk_consulta_paciente
    FOREIGN KEY (id_paciente)
    REFERENCES paciente(id_paciente),

    CONSTRAINT fk_consulta_medico
    FOREIGN KEY (id_medico)
    REFERENCES medico(id_medico),

    -- Impede duas consultas ao mesmo medico, na mesma data e hora
    CONSTRAINT uq_medico_horario
    UNIQUE (id_medico, data_consulta, hora_consulta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =====================================================
-- 3. CRIAR OS TRIGGERS
-- (criados antes dos dados, para validarem os INSERT)
-- =====================================================

DELIMITER //


-- TRIGGER 1:
-- Impedir a marcacao de consultas em datas passadas.

CREATE TRIGGER trg_verificar_data_consulta
BEFORE INSERT ON consulta
FOR EACH ROW
BEGIN
    IF NEW.data_consulta < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Erro: nao e permitido marcar consultas para datas passadas.';
    END IF;
END //


-- TRIGGER 2:
-- Impedir a alteracao de uma consulta para uma data passada.
-- So valida quando a data e realmente alterada, para ser
-- possivel marcar como 'Realizada' uma consulta que ja passou.

CREATE TRIGGER trg_actualizar_data_consulta
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN
    IF NEW.data_consulta <> OLD.data_consulta
       AND NEW.data_consulta < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Erro: a nova data da consulta nao pode ser passada.';
    END IF;
END //


-- TRIGGER 3:
-- Impedir a marcacao de consultas com medicos inactivos.

CREATE TRIGGER trg_verificar_medico
BEFORE INSERT ON consulta
FOR EACH ROW
BEGIN
    DECLARE estado_medico VARCHAR(20);

    SELECT estado INTO estado_medico
    FROM medico
    WHERE id_medico = NEW.id_medico;

    IF estado_medico = 'Inactivo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Erro: nao e possivel marcar consulta com medico inactivo.';
    END IF;
END //

DELIMITER ;


-- =====================================================
-- 4. INSERIR DADOS DE EXEMPLO
-- =====================================================

-- PACIENTES

INSERT INTO paciente
(nome, sexo, data_nascimento, telefone, endereco)
VALUES
('Joao Manuel', 'Masculino', '1998-05-12',
 '841234567', 'Chimoio'),
('Ana Carlos', 'Feminino', '2000-08-20',
 '861234567', 'Bairro 25 de Junho'),
('Pedro Alberto', 'Masculino', '1995-03-15',
 '871234567', 'Bairro 7 de Abril');


-- ESPECIALIDADES

INSERT INTO especialidade
(nome_especialidade, descricao)
VALUES
('Clinica Geral', 'Atendimento medico geral'),
('Pediatria', 'Atendimento medico infantil'),
('Cardiologia', 'Tratamento de doencas do coracao');


-- MEDICOS

INSERT INTO medico
(nome, telefone, email, id_especialidade)
VALUES
('Dr. Paulo Alberto', '871111111',
 'paulo@email.com', 1),
('Dra. Maria Jose', '881111111',
 'maria@email.com', 2),
('Dr. Carlos Pedro', '861111111',
 'carlos@email.com', 3);


-- CONSULTAS
-- As datas sao calculadas a partir do dia de hoje (CURDATE),
-- por isso o script funciona sempre, sem editar datas.

INSERT INTO consulta
(id_paciente, id_medico, data_consulta,
 hora_consulta, motivo, estado)
VALUES
(1, 1, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '09:00:00',
 'Dor de cabeca', 'Marcada'),
(2, 2, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '10:00:00',
 'Consulta de rotina', 'Marcada'),
(3, 3, DATE_ADD(CURDATE(), INTERVAL 4 DAY), '11:00:00',
 'Exame cardiologico', 'Marcada');


-- =====================================================
-- 5. CONSULTAS SQL PARA TESTAR O SISTEMA
-- =====================================================

-- VISUALIZAR TODOS OS PACIENTES

SELECT * FROM paciente;


-- VISUALIZAR TODAS AS ESPECIALIDADES

SELECT * FROM especialidade;


-- VISUALIZAR TODOS OS MEDICOS

SELECT * FROM medico;


-- VISUALIZAR TODAS AS CONSULTAS

SELECT * FROM consulta;


-- CONSULTAR MEDICOS E AS SUAS ESPECIALIDADES

SELECT
    m.id_medico,
    m.nome AS medico,
    m.telefone,
    e.nome_especialidade
FROM medico m
INNER JOIN especialidade e
ON m.id_especialidade = e.id_especialidade;


-- CONSULTAR AS CONSULTAS COM INFORMACOES COMPLETAS

SELECT
    c.id_consulta,
    p.nome AS paciente,
    m.nome AS medico,
    e.nome_especialidade,
    c.data_consulta,
    c.hora_consulta,
    c.motivo,
    c.estado
FROM consulta c
INNER JOIN paciente p
    ON c.id_paciente = p.id_paciente
INNER JOIN medico m
    ON c.id_medico = m.id_medico
INNER JOIN especialidade e
    ON m.id_especialidade = e.id_especialidade;


-- CONSULTAR APENAS AS CONSULTAS MARCADAS

SELECT *
FROM consulta
WHERE estado = 'Marcada';


-- CONSULTAR AS CONSULTAS DE UM PACIENTE

SELECT
    p.nome AS paciente,
    c.data_consulta,
    c.hora_consulta,
    c.motivo,
    c.estado
FROM consulta c
INNER JOIN paciente p
ON c.id_paciente = p.id_paciente
WHERE p.id_paciente = 1;


-- =====================================================
-- 6. EXEMPLOS DE ACTUALIZACAO
-- =====================================================

-- ACTUALIZAR O ESTADO DE UMA CONSULTA

UPDATE consulta
SET estado = 'Realizada'
WHERE id_consulta = 1;


-- DESACTIVAR UM MEDICO

UPDATE medico
SET estado = 'Inactivo'
WHERE id_medico = 3;


-- =====================================================
-- 7. VERIFICAR TRIGGERS E ESTRUTURA
-- =====================================================

SHOW TRIGGERS;

SHOW TABLES;


-- =====================================================
-- 8. TESTES DOS TRIGGERS (PARA A DEMONSTRACAO)
-- Estao comentados para nao darem erro ao correr o script.
-- Para testar, seleccionar UMA linha de cada vez, retirar
-- os "-- " e executar. Todos devem devolver erro.
-- =====================================================

-- Teste 1: data passada (deve falhar)
-- INSERT INTO consulta (id_paciente, id_medico, data_consulta, hora_consulta, motivo)
-- VALUES (1, 1, '2020-01-01', '08:00:00', 'Teste data passada');

-- Teste 2: medico inactivo (deve falhar, o medico 3 foi desactivado acima)
-- INSERT INTO consulta (id_paciente, id_medico, data_consulta, hora_consulta, motivo)
-- VALUES (1, 3, DATE_ADD(CURDATE(), INTERVAL 5 DAY), '08:00:00', 'Teste medico inactivo');

-- Teste 3: mesmo medico, mesma data e hora (deve falhar, UNIQUE)
-- INSERT INTO consulta (id_paciente, id_medico, data_consulta, hora_consulta, motivo)
-- VALUES (2, 1, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '09:00:00', 'Teste conflito de horario');
