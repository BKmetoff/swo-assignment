variable "resource_identifier" {
  description = "A name to identify AWS resources by"
  default     = "swo-assignment"
  type        = string
}

variable "db_username" {
  description = "The username to be used for the RDS root used"
  default     = "swo"
  type        = string
}

# Provide the PW via a CLI flag, e.g.:
# terraform apply -var db_password="super-secure-pw-420"
variable "db_password" {
  description = "The password of the DB user"
  type        = string
}

variable "aws_region" {
  default     = "eu-west-1"
  description = "The region to provision resources in"
  type        = string
}
