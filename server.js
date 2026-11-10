const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
const PORT = process.env.PORT || 3000;
const DB_NAME = process.env.DB_NAME || "gestao_consultas";
const DB_URL = process.env.DATABASE_URL || process.env.MYSQL_URL;

if (!DB_URL) {
  console.error("Falta a variavel DATABASE_URL (ex.: ${{MySQL.MYSQL_URL}} no Railway).");
  process.exit(1);
}

// A URL do Railway aponta para a base "railway"; usamos a base do projeto (DB_NAME).
const u = new URL(DB_URL);
const pool = mysql.createPool({
  host: u.hostname,
  port: Number(u.port) || 3306,
  user: decodeURIComponent(u.username),
  password: decodeURIComponent(u.password),
  database: DB_NAME,
  charset: "utf8mb4",
  dateStrings: true,
  connectionLimit: 5,
});

app.use(express.static("public"));

app.get("/health", (req, res) => res.send("ok"));

app.get("/api/stats", async (req, res) => {
  const medico = parseInt(req.query.medico, 10) || 0;
  const filtroWhere = medico ? "WHERE c.id_medico = ?" : "";
  const filtroAnd = medico ? "AND c.id_medico = ?" : "";
  const p = medico ? [medico] : [];

  try {
    const [[k]] = await pool.query(
      `SELECT COUNT(*) AS total,
              COALESCE(SUM(c.estado = 'Marcada'), 0) AS marcadas,
              COALESCE(SUM(c.estado = 'Realizada'), 0) AS realizadas,
              COALESCE(SUM(c.estado = 'Cancelada'), 0) AS canceladas
       FROM consulta c ${filtroWhere}`, p);

    const [esp] = await pool.query(
      `SELECT e.nome_especialidade AS nome, COUNT(c.id_consulta) AS total
       FROM especialidade e
       LEFT JOIN medico m ON m.id_especialidade = e.id_especialidade
       LEFT JOIN consulta c ON c.id_medico = m.id_medico ${filtroAnd}
       GROUP BY e.id_especialidade, e.nome_especialidade
       ORDER BY e.nome_especialidade`, p);

    const [dia] = await pool.query(
      `SELECT c.data_consulta AS dia, COUNT(*) AS total
       FROM consulta c ${filtroWhere}
       GROUP BY c.data_consulta ORDER BY c.data_consulta`, p);

    const [proximas] = await pool.query(
      `SELECT c.data_consulta AS data, c.hora_consulta AS hora,
              p.nome AS paciente, m.nome AS medico, c.motivo
       FROM consulta c
       JOIN paciente p ON c.id_paciente = p.id_paciente
       JOIN medico m ON c.id_medico = m.id_medico
       WHERE c.estado = 'Marcada' AND c.data_consulta >= CURDATE() ${filtroAnd}
       ORDER BY c.data_consulta, c.hora_consulta LIMIT 10`, p);

    const [medicos] = await pool.query(
      "SELECT id_medico AS id, nome FROM medico ORDER BY nome");

    res.json({
      baseDeDados: DB_NAME,
      atualizadoEm: new Date().toISOString(),
      kpis: {
        total: Number(k.total), marcadas: Number(k.marcadas),
        realizadas: Number(k.realizadas), canceladas: Number(k.canceladas),
      },
      porEspecialidade: esp.map(r => ({ nome: r.nome, total: Number(r.total) })),
      porDia: dia.map(r => ({ dia: r.dia, total: Number(r.total) })),
      proximas,
      medicos,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: err.code || "ERRO", mensagem: err.message });
  }
});

app.listen(PORT, "0.0.0.0", () => console.log("Painel a correr na porta " + PORT));
