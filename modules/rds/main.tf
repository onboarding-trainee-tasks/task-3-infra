locals { 
  db_secrets = jsondecode(var.db_secret_id.secret_string)
}

resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = local.db_secrets.db_username 
  password               = local.db_secrets.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  db_name                = var.db_name
  
  skip_final_snapshot    = true
}

# resource "aws_db_instance" "replica" {
#   instance_class         = "db.t3.micro"
#   allocated_storage      = 5
#   db_subnet_group_name   = aws_db_subnet_group.this.name
#   replicate_source_db    = aws_db_instance.this.id

#   skip_final_snapshot = true
# }