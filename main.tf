locals {
  docker_image_name = var.resource_identifier
  docker_image_tag  = "latest"

  db_instance_class    = "db.t3.micro"
  db_allocated_storage = 5
  db_engine            = "mysql"
  db_engine_version    = "8.0.33"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }

  backend "s3" {
    key     = "swo-assignment-tf-state.tfstate"
    bucket  = "swo-assignment-tf-state"
    region  = "eu-west-1"
    encrypt = true
    acl     = "bucket-owner-full-control"
  }
}


provider "aws" {
  profile = "default"
  region  = var.aws_region
}

module "vpc" {
  source = "./modules/VPC"

  aws_region         = var.aws_region
  name               = var.resource_identifier
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]

  rds_instance_id = module.rds.rds_instance_id

}

module "ecr" {
  source = "./modules/ECR"

  name = var.resource_identifier
}


data "aws_caller_identity" "current" {}

module "ecs" {
  source = "./modules/ECS"

  name                            = var.resource_identifier
  aws_region                      = var.aws_region
  account_id                      = data.aws_caller_identity.current.account_id
  private_subnet_ids              = module.vpc.private_subnet_ids
  vpc_id                          = module.vpc.vpc_id
  load_balancer_target_group_id   = module.vpc.load_balancer_target_group_id
  load_balancer_target_group_arn  = module.vpc.load_balancer_target_group_arn
  load_balancer_security_group_id = module.vpc.load_balancer_security_group_id
  efs_system_id                   = module.efs.system_id

  # Request a tiny amount of resources
  # to demonstrate autoscaling
  # based on CPU and memory usage.
  container_specs = {
    port = 80
    resources = {
      cpu    = 256
      memory = 512
    }
    image = {
      name = local.docker_image_name,
      tag  = local.docker_image_tag
    }
  }

  # After the RDS instance has been provisioned,
  # the DB parameters are injected into the
  # ECS task definition as environment variables,
  rds_env_vars = {
    db_name     = replace(var.resource_identifier, "-", "_") # swo-assignment -> swo_assignment
    db_hostname = module.rds.rds_hostname
    port        = module.rds.rds_port
    user        = module.rds.rds_username
    password    = var.db_password
  }

  depends_on = [module.ecr]
}

module "rds" {
  source = "./modules/RDS"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids

  ssh_security_group_id      = module.vpc.ssh_security_group_id
  esc_task_security_group_id = module.ecs.esc_task_security_group_id

  identifier        = var.resource_identifier
  instance_class    = local.db_instance_class
  allocated_storage = local.db_allocated_storage
  engine            = local.db_engine
  engine_version    = local.db_engine_version
  username          = var.db_username
  password          = var.db_password
}


module "efs" {
  source = "./modules/EFS"

  name               = var.resource_identifier
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.ecs.esc_task_security_group_id]
  ecs_cluster_id     = module.ecs.ecr_cluster_id
}

module "ec2_bastion" {
  source = "./modules/EC2_bastion"

  name                  = var.resource_identifier
  connection_params     = module.rds.connection_params
  db_password           = var.db_password
  ssh_security_group_id = module.vpc.ssh_security_group_id
  subnet_ids            = module.vpc.public_subnet_ids
}
