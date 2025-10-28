# Clean Architecture - Order System

Sistema de gerenciamento de pedidos (orders) desenvolvido seguindo os princípios de Clean Architecture, com múltiplas interfaces de acesso (REST API, gRPC e GraphQL).

## 📑 Índice

- [📋 Descrição do Projeto](#-descrição-do-projeto)
- [🏗️ Arquitetura](#️-arquitetura)
- [🚀 Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [📦 Pré-requisitos](#-pré-requisitos)
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuração](#-configuração)
- [🐳 Executando com Docker](#-executando-com-docker)
- [🗄️ Migrations](#️-migrations)
- [▶️ Executando a Aplicação](#️-executando-a-aplicação)
- [📡 Portas dos Serviços](#-portas-dos-serviços)
- [🧪 Testando a Aplicação](#-testando-a-aplicação)
  - [REST API](#rest-api)
  - [GraphQL](#graphql)
  - [gRPC](#grpc)
  - [Arquivo order.http](#arquivo-orderhttp)
- [🗂️ Estrutura do Banco de Dados](#️-estrutura-do-banco-de-dados)
- [🛠️ Desenvolvimento](#️-desenvolvimento)
- [📚 Use Cases Implementados](#-use-cases-implementados)
- [🔍 Troubleshooting](#-troubleshooting)
- [📄 Licença](#-licença)
- [👨‍💻 Autor](#-autor)

## 📋 Descrição do Projeto

Este projeto implementa um sistema completo de criação e listagem de pedidos utilizando:

- **REST API** - Endpoints HTTP para criar e listar pedidos
- **gRPC** - Serviço de alta performance para comunicação entre microsserviços
- **GraphQL** - API flexível para consultas customizadas
- **RabbitMQ** - Sistema de mensageria para eventos
- **MySQL** - Banco de dados relacional

## 🏗️ Arquitetura

O projeto segue os princípios de Clean Architecture com a seguinte estrutura:

```
.
├── cmd/
│   └── ordersystem/          # Ponto de entrada da aplicação
├── internal/
│   ├── entity/               # Entidades de domínio
│   ├── usecase/              # Casos de uso (regras de negócio)
│   ├── infra/
│   │   ├── database/         # Implementação de repositórios
│   │   ├── web/              # Handlers REST
│   │   ├── grpc/             # Serviços gRPC
│   │   └── graph/            # Resolvers GraphQL
│   └── event/                # Sistema de eventos
├── pkg/
│   └── events/               # Event dispatcher
└── api/
    └── order.http            # Exemplos de requisições HTTP
```

## 🚀 Tecnologias Utilizadas

- **Go 1.24+** - Linguagem de programação
- **MySQL 8.0** - Banco de dados
- **RabbitMQ** - Message broker
- **Docker & Docker Compose** - Containerização
- **golang-migrate** - Gerenciamento de migrations
- **gRPC** - Framework RPC
- **GraphQL (gqlgen)** - API GraphQL
- **Chi Router** - Router HTTP
- **Wire** - Injeção de dependências
- **Viper** - Gerenciamento de configurações

## 📦 Pré-requisitos

- Docker e Docker Compose instalados
- Go 1.24 ou superior (para desenvolvimento)
- Protocol Buffers Compiler (protoc) - para gerar código gRPC
- Evans CLI (opcional) - para testar gRPC

## ⚡ Quick Start

Siga estes passos para executar o projeto rapidamente:

### 1️⃣ Clone o repositório

```bash
git clone git@github.com:adalbertofjr/clean-arch-desafio-3.git
cd clean-arch-desafio-3
```

### 2️⃣ Execute o Docker Compose

Inicie os serviços de infraestrutura (MySQL, RabbitMQ e Migrations):

```bash
docker-compose up -d
```

Aguarde alguns segundos para que o MySQL inicialize e as migrations sejam executadas automaticamente.

### 3️⃣ Inicie o servidor

Navegue até o diretório da aplicação e execute:

```bash
cd cmd/ordersystem
go run main.go wire_gen.go
```

O servidor iniciará com os seguintes serviços:
- 🌐 REST API na porta `8000`
- 🔌 gRPC na porta `50051`
- 📊 GraphQL na porta `8080`

### 4️⃣ Teste a REST API

Use o arquivo `api/order.http` (com extensão REST Client no VS Code) ou execute:

```bash
# Criar um pedido
curl -X POST http://localhost:8000/order \
  -H "Content-Type: application/json" \
  -d '{"id":"order-001","price":100.5,"tax":0.5}'

# Listar pedidos
curl http://localhost:8000/orders
```

### 5️⃣ Teste o GraphQL

Acesse o playground GraphQL em: **http://localhost:8080**

Execute uma query:

```graphql
query listOrders{
  listOrders{
    id,
    Price,
    Tax,
    FinalPrice
  }
}
```

Ou uma mutation:

```graphql
mutation createOrder{
  createOrder(input: {id: "order-003", Price: 200.0, Tax: 10.0}) {
    id
    FinalPrice
  }
}
```

### 6️⃣ Teste o gRPC com Evans

Instale o Evans CLI (se ainda não tiver):

```bash
# macOS
brew install evans

# Ou via Go
go install github.com/ktr0731/evans@latest
```

Conecte-se ao servidor gRPC:

```bash
evans -r repl -p 50051

# Dentro do Evans:
package pb
service OrderService

# Criar pedido
call CreateOrder

# Listar pedidos
call ListOrders
```

## 🔧 Configuração

### 1. Clone o repositório

```bash
git clone git@github.com:adalbertofjr/clean-arch-desafio-3.git
cd clean-arch-desafio-3
```

### 2. Configure as variáveis de ambiente

O arquivo `.env` está localizado em `cmd/ordersystem/.env`:

```env
DB_DRIVER=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=orders
WEB_SERVER_PORT=:8000
GRPC_SERVER_PORT=50051
GRAPHQL_SERVER_PORT=8080
```

## 🐳 Executando com Docker

### Subir toda a infraestrutura

O projeto está configurado para subir automaticamente toda a infraestrutura necessária:

```bash
docker-compose up -d
```

Isso irá:
1. **Iniciar o MySQL** na porta `3306` com healthcheck
2. **Iniciar o RabbitMQ** na porta `5672` (management UI na porta `15672`)
3. **Executar as migrations automaticamente** assim que o MySQL estiver pronto

### Verificar se tudo está rodando

```bash
# Ver status dos containers
docker-compose ps

# Ver logs das migrations
docker-compose logs migrate

# Ver logs do MySQL
docker-compose logs mysql
```

### Parar os serviços

```bash
# Parar todos os containers
docker-compose down

# Parar e remover volumes (⚠️ apaga os dados do banco)
docker-compose down -v
```

## 🗄️ Migrations

As migrations são executadas automaticamente pelo Docker Compose, mas você também pode gerenciá-las manualmente:

### Executar migrations manualmente

```bash
# Executar todas as migrations pendentes
docker-compose run --rm migrate -path /migrations -database "mysql://root:root@tcp(mysql:3306)/orders" up

# Executar apenas 1 migration
docker-compose run --rm migrate -path /migrations -database "mysql://root:root@tcp(mysql:3306)/orders" up 1

# Verificar versão atual
docker-compose run --rm migrate -path /migrations -database "mysql://root:root@tcp(mysql:3306)/orders" version
```

### Rollback de migrations

```bash
# Fazer rollback de todas as migrations
docker-compose run --rm migrate -path /migrations -database "mysql://root:root@tcp(mysql:3306)/orders" down

# Fazer rollback de 1 migration
docker-compose run --rm migrate -path /migrations -database "mysql://root:root@tcp(mysql:3306)/orders" down 1
```

### Criar nova migration

```bash
# Instalar golang-migrate localmente (uma vez)
# macOS
brew install golang-migrate

# Ou via Go
go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Criar nova migration
migrate create -ext=sql -dir=sql/migrations -seq nome_da_migration
```

Isso criará dois arquivos:
- `000002_nome_da_migration.up.sql` - Para aplicar a migration
- `000002_nome_da_migration.down.sql` - Para reverter a migration

## ▶️ Executando a Aplicação

### Opção 1: Com Go instalado

```bash
cd cmd/ordersystem
go run main.go wire_gen.go
```

### Opção 2: Build e executar

```bash
cd cmd/ordersystem
go build -o ordersystem
./ordersystem
```

## 📡 Portas dos Serviços

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| REST API | `8000` | Endpoints HTTP |
| gRPC | `50051` | Serviço gRPC |
| GraphQL | `8080` | API GraphQL |
| MySQL | `3306` | Banco de dados |
| RabbitMQ | `5672` | Message broker |
| RabbitMQ Management | `15672` | Interface web do RabbitMQ |

## 🧪 Testando a Aplicação

### REST API

#### Criar um pedido (POST)

```bash
curl -X POST http://localhost:8000/order \
  -H "Content-Type: application/json" \
  -d '{
    "id": "order-001",
    "price": 100.5,
    "tax": 0.5
  }'
```

#### Listar todos os pedidos (GET)

```bash
curl http://localhost:8000/orders
```

### GraphQL

Acesse o playground GraphQL em: `http://localhost:8080`

#### Query - Listar pedidos

```graphql
query {
  listOrders {
    id
    Price
    Tax
    FinalPrice
  }
}
```

#### Mutation - Criar pedido

```graphql
mutation {
  createOrder(input: {
    id: "order-002"
    Price: 200.0
    Tax: 10.0
  }) {
    id
    Price
    Tax
    FinalPrice
  }
}
```

### gRPC

#### Usando Evans CLI

```bash
# Conectar ao servidor gRPC
evans -r repl -p 50051

# Dentro do Evans
package pb
service OrderService

# Criar um pedido
call CreateOrder
# Preencha os campos quando solicitado:
# id: order-003
# price: 150.0
# tax: 7.5

# Listar pedidos
call ListOrders
# Pressione Ctrl+D quando solicitado (Empty message)
```

#### Usando grpcurl

```bash
# Listar serviços disponíveis
grpcurl -plaintext localhost:50051 list

# Criar pedido
grpcurl -plaintext -d '{
  "id": "order-004",
  "price": 300.0,
  "tax": 15.0
}' localhost:50051 pb.OrderService/CreateOrder

# Listar pedidos
grpcurl -plaintext -d '{}' localhost:50051 pb.OrderService/ListOrders
```

### Arquivo order.http

Use o arquivo `api/order.http` com extensões como REST Client (VS Code) ou HTTP Client (IntelliJ):

```http
### Criar um pedido
POST http://localhost:8000/order HTTP/1.1
Host: localhost:8000
Content-Type: application/json

{
    "id":"order-005",
    "price": 100.5,
    "tax": 0.5
}

### Listar todos os pedidos
GET http://localhost:8000/orders HTTP/1.1
Host: localhost:8000
```

## 🗂️ Estrutura do Banco de Dados

### Tabela: orders

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | VARCHAR(255) | Identificador único do pedido (PK) |
| price | FLOAT | Preço do pedido |
| tax | FLOAT | Taxa aplicada |
| final_price | FLOAT | Preço final (price + tax) |

## 🛠️ Desenvolvimento

### Estrutura de Migrations

As migrations estão localizadas em `sql/migrations/`:

```
sql/migrations/
├── 000001_init.up.sql     # Cria a tabela orders
└── 000001_init.down.sql   # Remove a tabela orders
```

### Gerar código gRPC

```bash
protoc --go_out=. --go-grpc_out=. internal/infra/grpc/protofiles/order.proto
```

### Gerar código GraphQL

```bash
go run github.com/99designs/gqlgen generate
```

### Executar testes

```bash
go test ./...
```

### Gerar injeção de dependências (Wire)

```bash
cd cmd/ordersystem
wire
```

### Acessar o banco de dados

```bash
# Via Docker
docker exec -it mysql mysql -uroot -proot orders

# Ou conectar de fora
mysql -h localhost -P 3306 -u root -proot orders
```

## 📚 Use Cases Implementados

### CreateOrder
- **REST**: `POST /order`
- **gRPC**: `CreateOrder`
- **GraphQL**: `mutation createOrder`

Cria um novo pedido calculando automaticamente o preço final (price + tax).

### ListOrders
- **REST**: `GET /orders`
- **gRPC**: `ListOrders`
- **GraphQL**: `query listOrders`

Lista todos os pedidos cadastrados no sistema.

## 🔍 Troubleshooting

### Porta já em uso

Se alguma porta estiver em uso, você pode alterar no arquivo `.env`:

```env
WEB_SERVER_PORT=:8001
GRPC_SERVER_PORT=50053
GRAPHQL_SERVER_PORT=8081
```

### Erro de conexão com o banco

Certifique-se de que o MySQL está rodando:

```bash
docker ps | grep mysql
```

Verifique os logs do MySQL:

```bash
docker-compose logs mysql
```

### Migrations não foram executadas

Verifique os logs do serviço de migration:

```bash
docker-compose logs migrate
```

Execute manualmente se necessário:

```bash
docker-compose run --rm migrate -path /migrations -database "mysql://root:root@tcp(mysql:3306)/orders" up
```

### RabbitMQ não conecta

Verifique se o RabbitMQ está ativo:

```bash
docker ps | grep rabbitmq
```

Acesse o management: `http://localhost:15672` (usuário: `guest`, senha: `guest`)

### Problema com arquitetura ARM64 (Apple Silicon)

O projeto está configurado com `platform: linux/amd64` no docker-compose para garantir compatibilidade. Se tiver problemas de performance, você pode remover essa linha, pois MySQL 8.0 tem suporte nativo para ARM64.

### Limpar ambiente e começar do zero

```bash
# Parar containers e remover volumes
docker-compose down -v

# Remover pasta de dados do MySQL
rm -rf .docker/mysql

# Subir tudo novamente
docker-compose up -d
```

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais como parte do curso Full Cycle.

## 👨‍💻 Autor

Desenvolvido por Adalberto Fernandes Jr.

---

**Desafio Full Cycle - Clean Architecture**
