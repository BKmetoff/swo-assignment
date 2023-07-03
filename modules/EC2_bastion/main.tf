# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToInstance.html

resource "aws_instance" "bastion" {
  ami           = "ami-0e23c576dacf2e3df"
  instance_type = "t2.micro"

  # Assign the instance to the
  # first available public subnet
  # as it is only going to be
  # used for database initialization.
  subnet_id = var.subnet_ids[0]

  # Add the instance to
  # a security group attached to RDS
  # that opens port 443
  # so that it can connect to the DB.
  vpc_security_group_ids = [var.ssh_security_group_id]

  key_name = aws_key_pair.ec2_key_pair.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("${path.root}/ssh/id_rsa")
  }

  provisioner "file" {
    source      = "${path.root}/db/"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install mysql -y",
      "sudo mysql ${var.connection_params} -p${var.db_password} < /home/ec2-user/db_init.sql"
    ]
  }

  tags = {
    Name = "${var.name}-ec2-bastion"
  }
}


