resource "aws_db_instance" "rds_instance" {
  identifier              = "fds-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  storage_encrypted       = true
  backup_retention_period = 7
  deletion_protection     = false

  tags = {
    Name = var.db_name
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow access to RDS"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "upload_schema" {
  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${aws_db_instance.rds_instance.address} \
            -P 3306 \
            -u ${var.db_username} \
            -p${var.db_password} \
            ${var.db_name} < ../fds.sql
    EOT
  }

  depends_on = [aws_db_instance.rds_instance]
}
