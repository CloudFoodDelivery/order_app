# RDS Instance 1
resource "aws_db_instance" "rds_instance1" {
  allocated_storage      = 20
  storage_encrypted      = true
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = var.db_username1
  password               = var.db_password1
  vpc_security_group_ids = [var.sg_rds_id]
  skip_final_snapshot    = false

  tags = {
    Name = var.db_name1
  }
}

# RDS Instance 2
resource "aws_db_instance" "rds_instance2" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = var.db_username2
  password               = var.db_password2
  vpc_security_group_ids = [var.sg_rds_id]
  skip_final_snapshot    = false

  tags = {
    Name = var.db_name2
  }
}
