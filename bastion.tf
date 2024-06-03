resource "aws_security_group" "bastion_sg" {
  name        = "allow_tls"
  description = "Allow SSH inbound traffic from Interpretator VPN"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, {Name: "bastion_sg"})
}

resource "aws_security_group_rule" "bastion_sg_egress_rule" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.bastion_sg.id
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_instance" "bastion" {
  ami           = "ami-0233214e13e500f77"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = local.bastion_key_pair
  associate_public_ip_address = true
  subnet_id = module.vpc.public_subnets[0]

  root_block_device {
    delete_on_termination = true
    volume_type = "standard"
    encrypted = true
    volume_size = 8
  }

  tags = merge(local.tags, {Name: "bastion-tf"})
}

resource "aws_eip" "bastion-ip" {
  instance = aws_instance.bastion.id
}
