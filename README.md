# Sistema de Vendas

Aplicação full stack para gestão de produtos, clientes, vendas, recebimentos e relatórios.

## Tecnologias

- **Frontend:** React + Vite (HTML, CSS e JavaScript)
- **Backend:** Node.js + Express (API REST)
- **Banco:** SQLite (`node:sqlite`, embutido no Node.js 24)
- **Autenticação:** JWT + hash de senha com bcrypt
- **Testes:** `node:test` + Supertest
- **Versionamento:** Git

## Requisitos

- Node.js 24 ou superior (necessário para `node:sqlite`)
- npm

## Instalação

```bash
npm install
npm --prefix frontend install
cp .env.example .env   # Windows: copy .env.example .env
```

Edite o `.env` e defina um `JWT_SECRET` longo e aleatório antes de usar em produção.

## Execução

```bash
# API + frontend no mesmo comando
npm run dev
```

- API: http://localhost:3000
- Frontend: http://localhost:5173

Outros comandos:

```bash
npm start          # somente API
npm test           # testes formais dos serviços/API
npm --prefix frontend run build
```

## Publicação na AWS

O projeto inclui `Dockerfile`, configuração do Elastic Beanstalk e um guia completo em
[`deploy/aws/README.md`](deploy/aws/README.md). O deploy gera uma URL pública única para
frontend e API, por exemplo `http://<ambiente>.us-east-1.elasticbeanstalk.com`.

## Primeiro acesso

Não há usuários pré-cadastrados. Acesse `/login`, clique em **Criar conta** e cadastre o primeiro
usuário: ele receberá automaticamente o perfil **admin**. Todos os seguintes serão **operador**.

- **Admin:** gerencia produtos e clientes.
- **Operador:** consulta cadastros, registra vendas e baixa pagamentos.
- Todas as rotas `/api/*`, exceto `/api/auth/register` e `/api/auth/login`, exigem o header
  `Authorization: Bearer <token>`.

## Regras de negócio

- Produtos guardam preço em centavos e estoque inteiro.
- Uma venda contém um ou mais itens; cada item congela nome, unidade e preço praticado.
- A venda e a baixa de estoque ocorrem em **uma transação SQLite** (`BEGIN IMMEDIATE`).
  Se qualquer item não tiver estoque suficiente, nada é gravado.
- Formas de pagamento: `cash`, `pix`, `card` e `credit`.
- Vendas `credit` começam com status `pending`; as demais já nascem `paid`.
- O pagamento de uma venda pendente pode ser baixado **uma única vez**.
- Cliente é opcional na venda (consumidor final).
- O relatório `/api/reports/sales-by-client` agrupa vendas por cliente em um período,
  com totais pago e pendente.

## Endpoints principais

| Método | Rota | Descrição | Perfil |
| --- | --- | --- | --- |
| POST | `/api/auth/register` | Criar conta (primeira = admin) | público |
| POST | `/api/auth/login` | Login e JWT | público |
| GET | `/api/auth/me` | Dados do usuário autenticado | autenticado |
| GET/POST | `/api/products` | Listar / criar produto | leitura: todos · escrita: admin |
| GET/PUT | `/api/products/:id` | Detalhes / atualizar produto | leitura: todos · escrita: admin |
| GET/POST | `/api/clients` | Listar / criar cliente | leitura: todos · escrita: admin |
| GET/PUT | `/api/clients/:id` | Detalhes / atualizar cliente | leitura: todos · escrita: admin |
| GET/POST | `/api/sales` | Histórico / registrar venda | autenticado |
| GET | `/api/sales/:id` | Detalhes da venda | autenticado |
| POST | `/api/sales/:id/payment` | Baixar pagamento pendente | autenticado |
| GET | `/api/reports/sales-by-client?from=AAAA-MM-DD&to=AAAA-MM-DD` | Relatório por cliente | autenticado |

## Estrutura

```
src/
  app.js                 # Express, rotas, CORS e tratamento de erros
  db.js                  # schema SQLite e helper de transação
  services/              # regras de negócio (auth, catálogo, vendas)
  routes/                # rotas REST
  middleware/auth.js     # verificação de JWT e perfil admin
  validation.js          # esquemas de validação
test/api.test.js         # testes node:test + Supertest
frontend/src/            # aplicação React
Dockerfile               # imagem única (React build + API)
.ebextensions/           # configuração do Elastic Beanstalk
deploy/aws/              # guia e exemplos de deploy na AWS
```
