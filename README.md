# Painel de Consultas Médicas (Node.js + MySQL no Railway)

Aplicação web que lê a base de dados `gestao_consultas` e mostra um painel em tempo real.

## Passo 1: preparar a base de dados
No MySQL Workbench, ligado ao Railway, executar por ordem:
1. `sql/01_gestao_consultas_railway.sql`
2. `sql/02_dados_dashboard.sql` (dados extra para o painel)

## Passo 2: enviar o código para o GitHub
1. Criar um repositório novo no GitHub (ex.: `dashboard-clinica`).
2. Em **Add file, Upload files**, enviar todos os ficheiros desta pasta (incluindo `public` e `sql`).

## Passo 3: colocar no Railway
1. No projeto Railway: **+ New, GitHub Repo** e escolher o repositório.
2. Abrir o novo serviço, separador **Variables**, e criar:
   - `DATABASE_URL` com o valor `${{MySQL.MYSQL_URL}}` (usar o nome do teu serviço MySQL, se for diferente de "MySQL")
   - `DB_NAME` com o valor `gestao_consultas`
3. **Settings, Networking, Generate Domain** para obter o link público.
4. Abrir o link: o painel aparece com os dados da base de dados.

## Testar no computador (opcional)
```
npm install
DATABASE_URL="mysql://root:PASSWORD@HOST:PORTA/railway" DB_NAME=gestao_consultas npm start
```
Usar o host e a porta do `MYSQL_PUBLIC_URL`. Abrir http://localhost:3000

## Problemas comuns
- **Unknown database 'gestao_consultas'**: falta executar o script 01.
- **Table doesn't exist**: o script 01 não correu até ao fim.
- **ENOTFOUND mysql.railway.internal** no computador: a URL interna só funciona dentro do Railway; localmente usar o MYSQL_PUBLIC_URL.
- **Painel sem consultas futuras**: as datas dos dados são relativas ao dia em que o script correu; voltar a executar os scripts 01 e 02.
