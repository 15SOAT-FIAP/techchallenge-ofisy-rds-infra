########################################
# DATA SOURCES FOR NETWORK & SECURITY
########################################

# Busca a VPC da aplicação criada pela infraestrutura base/EKS
data "aws_vpc" "main" {
  count = var.vpc_id == "" ? 1 : 0

  filter {
    name   = "tag:Name"
    values = ["${local.project_name}-vpc"]
  }
}

locals {
  target_vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.main[0].id
}

# Busca as subnets privadas da VPC
data "aws_subnets" "private" {
  count = length(var.private_subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.target_vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.project_name}-private-subnet-*"]
  }
}

locals {
  target_subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : data.aws_subnets.private[0].ids
}

# Busca o Security Group do EKS para permitir tráfego no RDS
data "aws_security_group" "eks" {
  filter {
    name   = "vpc-id"
    values = [local.target_vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.project_name}-eks-sg"]
  }
}

# Busca o cluster EKS para permitir tráfego dos nós no RDS
data "aws_eks_cluster" "main" {
  name = "${local.project_name}-cluster"
}

