resource "aws_efs_file_system" "fs" {
  creation_token = "${var.name}-efs-token"

  tags = { Name = "${var.name}-efs-for-ecs-service" }
}

resource "aws_efs_mount_target" "efs_target" {
  count = length(var.subnet_ids)

  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = var.subnet_ids[count.index]
  # security_groups = var.security_group_ids
  security_groups = [aws_security_group.efs.id]
}

data "aws_iam_policy_document" "fs_policy" {
  statement {
    sid    = "ExampleStatement01"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.fs.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "fs_policy" {
  file_system_id = aws_efs_file_system.fs.id
  policy         = data.aws_iam_policy_document.fs_policy.json
}

resource "aws_security_group" "efs" {
  name        = "${var.name}-efs-sg-gr"
  description = "Allows NFS traffic from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
