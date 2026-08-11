# Ofisy - Infraestrutura do Banco de Dados Gerenciado (RDS PostgreSQL)

Este repositório é responsável pelo provisionamento automatizado via **Terraform** da infraestrutura do banco de dados relacional gerenciado **Amazon RDS PostgreSQL** para a plataforma **Ofisy**, conforme os requisitos do **Tech Challenge (Fase 3 - SOAT / FIAP)**.

---

## Propósito do Repositório

Garantir o isolamento, alta disponibilidade, segurança e gerenciamento do ciclo de vida do banco de dados PostgreSQL na AWS. O banco de dados é provisionado em subnets privadas dentro da VPC da aplicação e configurado com regras restritas de acesso via Security Groups.

---

## Estrutura do Repositório

```
techchallenge-ofisy-rds-infra/
├── .github/
│   └── workflows/
│       └── deploy-rds.yml      # Pipeline CI/CD no GitHub Actions
├── infra/
│   ├── main.tf                 # Configuração do provedor AWS e locals
│   ├── variables.tf            # Variáveis de entrada (db_password, account_id, etc.)
│   ├── data.tf                 # Busca dinâmica de VPC, Subnets e SG do EKS
│   ├── rds.tf                  # Instância RDS PostgreSQL e DB Subnet Group
│   ├── security_groups.tf      # Security Group do RDS e regras de tráfego
│   ├── outputs.tf              # Endpoints e saídas do banco de dados
│   ├── backend.tf              # Backend remoto no S3
│   ├── backend.hcl.example     # Exemplo de configuração do backend S3
│   └── terraform.tfvars.example# Exemplo de arquivo de variáveis
└── README.md                   # Documentação oficial do repositório
```

---

## Tecnologias Utilizadas

- **[Terraform](https://www.terraform.io/)** (>= 1.5.0): Infraestrutura como Código (IaC).
- **[Amazon RDS (Relational Database Service)](https://aws.amazon.com/rds/)**: Instância gerenciada do PostgreSQL 15.
- **[Amazon VPC](https://aws.amazon.com/vpc/)**: Subnet Groups e isolamento de rede privada.
- **[GitHub Actions](https://github.com/features/actions)**: Pipeline automatizada de CI/CD para plan e apply da infraestrutura.

---

## Arquitetura do Banco de Dados

```mermaid
graph TD
    subgraph AWS Cloud - us-east-1
        subgraph VPC ["VPC (ofisy-vpc)"]
            subgraph PrivateSubnets ["Subnets Privadas (AZ-a & AZ-b)"]
                DBSubnetGroup["DB Subnet Group (ofisy-db-subnet-group)"]
                RDSInstance["Amazon RDS PostgreSQL<br/>(ofisydb / db.t3.micro)"]
                DBSubnetGroup --> RDSInstance
            end

            subgraph SecurityGroups ["Segurança de Rede"]
                RDSSG["Security Group: ofisy-rds-sg<br/>Inbound: Porta 5432 apenas dos SGs autorizados"]
            end
        end

        EKSSG["EKS Cluster Security Group<br/>(ofisy-eks-sg)"] -->|Porta 5432| RDSSG
        LambdaSG["Lambda de Autenticacao<br/>(ofisy-lambda-auth-sg)"] -->|Porta 5432| RDSSG
        RDSSG --> RDSInstance
    end
```

Os dois Security Groups de origem são criados pela [infraestrutura base](https://github.com/15SOAT-FIAP/techchallenge-ofisy-eks-infra) e localizados aqui por tag. O SG da Lambda é criado lá, e não junto da função, para que esta regra de liberação não dependa do state da Lambda, que por sua vez depende deste banco.

---

## Ordem de Execução entre os Repositórios

Este repositório é a **etapa 3** de um fluxo de cinco. Ele não cria a rede: localiza a VPC, as subnets privadas e os Security Groups por tag, então a infraestrutura base precisa já estar provisionada. Da mesma forma, a Lambda de autenticação só pode ser criada depois que este banco existir.

```mermaid
flowchart TD
    P1["1 · eks-infra — infra/<br/>Rede, EKS, ECR e Security Groups"]
    P2["2 · techchallenge-ofisy-auth<br/>CD publica a imagem da Lambda no ECR"]
    P3["3 · techchallenge-ofisy-rds-infra<br/>Banco de dados RDS PostgreSQL"]
    P4["4 · eks-infra — infra-auth/<br/>Lambda de autenticacao"]
    P5["5 · techchallenge-ofisy<br/>Aplicacao Spring Boot no EKS"]

    P1 --> P2 --> P3 --> P4 --> P5
```

Se o `terraform plan` falhar aqui com um erro de que nenhum Security Group corresponde ao filtro, é sinal de que a etapa 1 não rodou ou rodou em uma versão anterior, que ainda não criava o `ofisy-lambda-auth-sg`.

Para **destruir**, siga o caminho inverso: a Lambda (etapa 4) precisa ser destruída antes deste banco.

---

## Passos para Execução e Deploy

### 1. Pré-requisitos Locais

- **Terraform CLI** (versão 1.5.0 ou superior)
- **AWS CLI** configurada com credenciais com permissão para gerenciar instâncias RDS e VPC.

### 2. Configuração do Backend e Variáveis

Acesse o diretório `infra/`:

```bash
cd infra
```

Crie o arquivo `infra/backend.hcl` para o Remote State do S3:

```hcl
bucket = "ofisy-tfstate-<SEU_AWS_ACCOUNT_ID>"
key    = "rds/terraform.tfstate"
region = "us-east-1"
```

Crie o arquivo `infra/terraform.tfvars`:

```hcl
account_id  = "<SEU_AWS_ACCOUNT_ID>"
db_password = "<SUA_SENHA_DO_BANCO_RDS>"
```

### 3. Execução dos Comandos Terraform

```bash
# Inicializa os provedores e o backend remoto
terraform init -backend-config=backend.hcl

# Visualiza o plano de execução
terraform plan

# Aplica as alterações e cria o RDS
terraform apply -auto-approve
```

---

## Pipeline CI/CD (GitHub Actions)

A pipeline é executada automaticamente em qualquer `push` ou `pull_request` nas branches `main`/`master`.

### Secrets Necessárias:

Definidas como **Organization Secrets** na org `15SOAT-FIAP`, compartilhadas entre os repositórios da Fase 3:

- `AWS_ACCESS_KEY_ID`: Chave de acesso AWS.
- `AWS_SECRET_ACCESS_KEY`: Chave secreta AWS.
- `AWS_SESSION_TOKEN`: Token de sessão (para AWS Academy / SSO).
- `AWS_ACCOUNT_ID`: ID numérico da conta AWS.
- `DB_PASSWORD`: Senha master do PostgreSQL (mínimo 8 caracteres).

---

## Repositórios Relacionados & Documentação

- **Aplicação Principal (Kubernetes):** [techchallenge-ofisy](https://github.com/15SOAT-FIAP/techchallenge-ofisy)
- **Infraestrutura Kubernetes (EKS):** [techchallenge-ofisy-eks-infra](https://github.com/15SOAT-FIAP/techchallenge-ofisy-eks-infra)
- **Documentação Swagger/Postman:** Disponível no endpoint da Aplicação Principal (`/swagger-ui/index.html`).
