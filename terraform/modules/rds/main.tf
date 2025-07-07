# Variables coming from terraform.tfvars and Lambda Output values:
variable "postgres_password" {}

data "aws_availability_zones" "available" {}

#Using "official" Terraform Module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.21.0
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name                 = "education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}

resource "aws_security_group" "rds" {
  name   = "education_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "education_rds"
  }
}

#This is optional, but useful for custom parameters in the DB:
resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.18"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.postgres_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true #in PROD Env should be "false"
}
#Inpiration from Terraform Documentation: https://developer.hashicorp.com/terraform/tutorials/aws/aws-rds?in=terraform%2Faws&utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS


resource "null_resource" "cluster" {
  depends_on = [aws_db_instance.education]

  # The trigger detects when a new DB Host URL changes, so it will apply this new Schema to the new DB:
  triggers = {
    db_endpoint = aws_db_instance.education.address
    schema_hash  = filemd5("../db/init_schema.sql")
  }

  provisioner "local-exec" {
    command = "psql -h ${aws_db_instance.education.address} -p ${aws_db_instance.education.port}  -U ${var.db_user} -d ${var.db_name} -f ../db/init_schema.sql"
    environment = {
      PGPASSWORD = var.postgres_password
    }
  }
}