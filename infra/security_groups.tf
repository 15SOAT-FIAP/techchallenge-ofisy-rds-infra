########################################
# SECURITY GROUP - RDS
########################################

# Cria um Security Group para controlar o acesso à instância RDS PostgreSQL.
resource "aws_security_group" "rds" {
  name        = "${local.project_name}-rds-sg"
  description = "Security Group para o banco de dados RDS PostgreSQL"
  vpc_id      = local.target_vpc_id

  tags = {
    Name = "${local.project_name}-rds-sg"
  }
}

# Permite conexões PostgreSQL provenientes do Security Group do EKS.
resource "aws_security_group_rule" "rds_postgres_from_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.eks.id
  security_group_id        = aws_security_group.rds.id
}

# Permite que a instância RDS realize conexões de saída para qualquer destino.
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}
