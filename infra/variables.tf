variable "account_id" {
  description = "ID da conta AWS"
  type        = string
}

variable "db_password" {
  description = "Senha do usuário administrativo do banco de dados PostgreSQL"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "A senha do banco de dados deve ter no mínimo 8 caracteres."
  }
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS será implantado (opcional se a VPC for buscada via Data Source)"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas para o DB Subnet Group (opcional se buscado via Data Source)"
  type        = list(string)
  default     = []
}
