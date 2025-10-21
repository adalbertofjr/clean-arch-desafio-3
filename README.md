# Clean Architecture - Order System

Sistema de gerenciamento de pedidos (orders) desenvolvido seguindo os princípios de Clean Architecture, com múltiplas interfaces de acesso (REST API, gRPC e GraphQL).

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
- **MySQL 5.7** - Banco de dados
- **RabbitMQ** - Message broker
- **Docker & Docker Compose** - Containerização
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
GRPC_SERVER_PORT=50052
GRAPHQL_SERVER_PORT=8080
```

## 🐳 Executando com Docker

### Subir a infraestrutura (MySQL e RabbitMQ)

```bash
docker-compose up -d
```

Isso irá iniciar:
- **MySQL** na porta `3306`
- **RabbitMQ** na porta `5672` (management UI na porta `15672`)

### Criar o banco de dados e tabelas

```bash
# Conectar ao MySQL
docker exec -it mysql mysql -uroot -proot

# Criar o banco de dados
CREATE DATABASE IF NOT EXISTS orders;
USE orders;

# Criar a tabela de orders
CREATE TABLE orders (
    id VARCHAR(255) NOT NULL,
    price FLOAT NOT NULL,
    tax FLOAT NOT NULL,
    final_price FLOAT NOT NULL,
    PRIMARY KEY (id)
);

# Sair
EXIT;
```

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
| gRPC | `50052` | Serviço gRPC |
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
evans -r repl -p 50052

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
grpcurl -plaintext localhost:50052 list

# Criar pedido
grpcurl -plaintext -d '{
  "id": "order-004",
  "price": 300.0,
  "tax": 15.0
}' localhost:50052 pb.OrderService/CreateOrder

# Listar pedidos
grpcurl -plaintext -d '{}' localhost:50052 pb.OrderService/ListOrders
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

### RabbitMQ não conecta

Verifique se o RabbitMQ está ativo:

```bash
docker ps | grep rabbitmq
```

Acesse o management: `http://localhost:15672` (usuário: `guest`, senha: `guest`)

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais como parte do curso Full Cycle.

## 👨‍💻 Autor

Desenvolvido por Adalberto Fernandes Jr.

---

**Desafio Full Cycle - Clean Architecture**
