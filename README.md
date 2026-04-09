<h1 align="center">
  ☁️ Snipe-IT Cloud Deployment
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white" />
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white" />
</p>

## Sobre o Projeto
Este repositório contém uma arquitetura **DevOps completa e automatizada** para o provisionamento do [Snipe-IT](https://snipeitapp.com/) (Sistema de Gestão de Ativos Open-Source) na nuvem pública AWS.

O objetivo do projeto é demonstrar práticas modernas de **Infraestrutura como Código (IaC)**, **Gestão de Configuração** e **CI/CD**, saindo do zero absoluto até uma aplicação web conteinerizada e pronta para uso corporativo, sem a necessidade de intervenção manual no servidor.

## Arquitetura
1. **Terraform (IaC):** Responsável por conversar com a AWS, provisionar uma máquina virtual (EC2) Ubuntu, liberar portas de Rede HTTP/SSH (Security Groups) e criar/salvar as chaves criptográficas (KeyPairs).
2. **S3 & DynamoDB (Remote State):** O cérebro do Terraform fica armazenado em um Bucket S3 isolado na nuvem, enquanto o DynamoDB gerencia o "State Lock" para impedir que execuções simultâneas corrompam a infraestrutura.
3. **Ansible (Configuration Management):** Lê o IP gerado pelo Terraform e conecta na máquina para instalar dependências vitais (Docker e Docker Compose), gerando os arquivos de ambiente `.env` e subindo a stack dinâmica.
4. **Docker Compose:** Orquestra os contêineres do Snipe-IT em PHP e seu banco de dados primário (MariaDB).
5. **GitHub Actions (CI/CD):** Esteira automatizada que atua como gatilho. A cada *Commit/Push* direcionado à branch `main`, o GitHub inicia um runner limpo, valida credenciais, invoca o Terraform e roda o Playbook do Ansible do começo ao fim.

## Como Funciona (Pipeline)

Ao realizar uma atualização de código neste repositório, o GitHub Actions executa os steps:
- Clonagem do repositório interno.
- Configuração do CLI do Terraform e Autenticação contra a AWS via *Secrets*.
- Execução do `terraform apply` visando convergência de estado S3.
- Parsing dinâmico de IPs e permissões Linux para o Ansible.
- Execução do Playbook (`setup_snipeit.yml`), aplicando idempotência sobre o servidor EC2 instanciado.

## Como replicar no seu ambiente

### Pré-requisitos:
- Uma conta ativa na [Amazon Web Services (AWS)](https://aws.amazon.com/).
- Crie um repositório interno próprio e configure as seguintes variáveis no **GitHub Secrets (Actions)**:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

### Setup Inicial do Backend S3:
Antes de o GitHub assumir o controle autônomo, execute o pequeno projeto isolado de setup (apenas uma vez) para habilitar o cofre de estado remoto:
```bash
cd backend-setup
terraform init && terraform apply
```

Pronto! Ao subir os códigos pro repositório `main`, relaxe e acompanhe o log da aba "Actions".

---
*Construído com automação e boas práticas de Engenharia DevOps.*
