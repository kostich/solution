locals {
  instance_userdata = <<USERDATA
#!/bin/bash
adduser ${var.instance_user}
mkdir /home/${var.instance_user}/.ssh
chmod 700 /home/${var.instance_user}/.ssh
${join(
  "; ",
  [
    for key in var.instance_keys :
    format(
      "echo %s >> /home/%s/.ssh/authorized_keys",
      key,
      var.instance_user,
    )
  ]
)}
chmod 600 /home/${var.instance_user}/.ssh/authorized_keys
chown -R ${var.instance_user}: /home/${var.instance_user}
USERDATA
}

resource "aws_eip" "vpn_instance_eip" {
  vpc = true

  tags = {
    Name = "${var.environment}-vpn-instance-eip"
  }
}

resource "aws_eip_association" "vpn_eip_assoc" {
  instance_id   = aws_instance.vpn_instance.id
  allocation_id = aws_eip.vpn_instance_eip.id
}

resource "aws_security_group" "vpn_sg" {
  name   = "${var.environment}-vpn-sg"
  vpc_id = aws_vpc.solution_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_network_interface" "vpn_nic" {
  subnet_id       = aws_subnet.public_primary.id
  security_groups = [aws_security_group.vpn_sg.id]

  tags = {
    Name = "vpn-nic"
  }
}

resource "aws_instance" "vpn_instance" {
  ami              = var.instance_ami
  instance_type    = var.instance_type
  user_data_base64 = base64encode(local.instance_userdata)

  network_interface {
    network_interface_id = aws_network_interface.vpn_nic.id
    device_index         = 0
  }

  tags = {
    Name = "${var.environment}-vpn"
  }

  depends_on = [
    aws_eip.vpn_instance_eip,
  ]
}