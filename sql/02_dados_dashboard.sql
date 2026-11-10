-- Dados extra para o painel ficar mais completo.
-- Executar DEPOIS de 01_gestao_consultas_railway.sql.
USE gestao_consultas;

-- O script principal desactiva o medico 3 (exemplo de UPDATE). Reactivamos para o painel.
UPDATE medico SET estado = 'Activo' WHERE id_medico = 3;

INSERT INTO paciente (nome, sexo, data_nascimento, telefone, endereco) VALUES
('Luisa Tembe',   'Feminino',  '1992-11-02', '842223344', 'Bairro Eduardo Mondlane'),
('Mario Sitoe',   'Masculino', '1988-01-27', '852223344', 'Bairro 1 de Maio'),
('Rita Macuacua', 'Feminino',  '2003-06-09', '822223344', 'Chimoio');

-- As datas sao relativas a hoje, para passarem sempre nos triggers.
INSERT INTO consulta (id_paciente, id_medico, data_consulta, hora_consulta, motivo, estado) VALUES
(4, 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:30:00', 'Dor de costas',        'Marcada'),
(5, 2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:30:00', 'Febre',                'Marcada'),
(6, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:30:00', 'Controlo de tensao',   'Cancelada'),
(1, 2, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '08:00:00', 'Vacinacao',            'Marcada'),
(2, 1, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00:00', 'Consulta de rotina',   'Realizada'),
(3, 3, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '11:00:00', 'Exame cardiologico',   'Marcada'),
(4, 1, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '10:00:00', 'Dor de garganta',      'Marcada'),
(5, 3, DATE_ADD(CURDATE(), INTERVAL 5 DAY), '09:00:00', 'Palpitacoes',          'Marcada'),
(6, 2, DATE_ADD(CURDATE(), INTERVAL 5 DAY), '10:00:00', 'Tosse',                'Cancelada'),
(2, 1, DATE_ADD(CURDATE(), INTERVAL 6 DAY), '08:30:00', 'Dor de cabeca',        'Marcada'),
(1, 3, DATE_ADD(CURDATE(), INTERVAL 6 DAY), '11:30:00', 'Controlo cardiologico','Realizada');

SELECT COUNT(*) AS total_consultas FROM consulta;
