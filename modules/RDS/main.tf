resource "aws_db_subnet_group" "db_subnet_gr" {
  name       = "${var.identifier}-rds-subnet"
  subnet_ids = var.public_subnets
}

resource "aws_db_parameter_group" "db_param_gr" {
  name   = "${var.identifier}-rds-param-gr"
  family = "mysql8.0"
}

resource "aws_security_group" "rds" {
  name   = "${var.identifier}-rds-sec-gr"
  vpc_id = var.vpc_id

  ingress {
    description = "Allows traffic to and from MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allows traffic to and from MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.identifier}-rds-sec-gr"
  }
}


resource "aws_db_instance" "rds" {
  identifier           = "${var.identifier}-rds"
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  username             = var.username
  password             = var.password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_gr.name
  parameter_group_name = aws_db_parameter_group.db_param_gr.name
  multi_az             = true
  publicly_accessible  = false
  skip_final_snapshot  = true

  vpc_security_group_ids = [
    aws_security_group.rds.id,
    var.ssh_security_group_id,
    var.esc_task_security_group_id
  ]
}
