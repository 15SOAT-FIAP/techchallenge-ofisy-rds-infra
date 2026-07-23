########################################
# DB SUBNET GROUP
########################################

# DB Subnet Group exigido pelo RDS em subnets privadas de pelo menos 2 AZs
resource "aws_db_subnet_group" "main" {
  name       = "${local.project_name}-db-subnet-group"
  subnet_ids = local.target_subnet_ids

  tags = {
    Name = "${local.project_name}-db-subnet-group"
  }
}

########################################
# RDS POSTGRESQL DATABASE
########################################

# Instância Amazon RDS PostgreSQL gerenciada
resource "aws_db_instance" "main" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = "ofisy"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  db_name = "ofisydb"

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  multi_az            = false
  publicly_accessible = false
  storage_encrypted   = true

  tags = {
    Name = "${local.project_name}-postgres-db"
  }

  depends_on = [
    aws_security_group.rds,
    aws_db_subnet_group.main
  ]
}
