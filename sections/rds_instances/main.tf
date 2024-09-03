# RDS Instance 1
resource "aws_db_instance" "rds_instance1" {
    allocated_storage       = 20
    engine                  = "mysql"
    instance_class          = "db.t3.micro"
    name                    = "rds_instance1"
    username                = "admin1"
    password                = "333Delivery!"
    vpc_security_group_ids  = [aws_security_group.sg_rds.id]
    subnet_id               = aws_subnet.private_db_subnet1.id
    skip_final_snapshot     = false
    
    tags = {
        Name = "rds_instance1"
    }
}

# RDS Instance 2
resource "aws_db_instance" "rds_instance2" {
    allocated_storage       = 20
    engine                  = "mysql"
    instance_class          = "db.t3.micro"
    name                    = "rds_instance2"
    username                = "admin2"
    password                = "BBBDelivery!"
    vpc_security_group_ids  = [aws_security_group.sg_rds.id]
    subnet_id               = aws_subnet.private_db_subnet2.id
    skip_final_snapshot     = false
    
    tags = {
        Name = "rds_instance2"
    }
}
