resource "random_password" "dbpassword" {
length          = 10
special         = false
lower           = true
min_lower       = 2
number          = true
min_upper       = 2
}

#db instance
resource "aws_db_instance" "mysqldb" {
  availability_zone    = var.azs
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  identifier           = var.identifier
  name                 = var.name
  username             = var.username
  password             = random_password.dbpassword.result
  port                 = var.port
  publicly_accessible  = false
  parameter_group_name        = aws_db_parameter_group.mysqldbparamgrp.name
  skip_final_snapshot         = true
  allow_major_version_upgrade = true
  vpc_security_group_ids = var.vpc_security_group_ids
  maintenance_window          = var.maintenance_window
  backup_window               = var.backup_window
  deletion_protection         = false
}

#database parameter group
resource "aws_db_parameter_group" "mysqldbparamgrp" {
  name   = var.parameter_group_name
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

#secretsmanager to store rds credentials
resource "aws_secretsmanager_secret" "dbsecrets2" {
  name = "dbsecretsmysql2"
   description = "RDS credentials"
}

#Store username and password
resource "aws_secretsmanager_secret_version" "mysqldb_credentials2" {
  secret_id = aws_secretsmanager_secret.dbsecrets2.id
  secret_string = <<EOF
   {
    "username": aws_db_instance.mysqldb.username,
    "password": aws_db_instance.mysqldb.password
   }
EOF
}
