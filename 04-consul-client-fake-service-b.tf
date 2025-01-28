resource "aws_instance" "consul-client-b" {
  depends_on             = [aws_instance.consul-server]
  count                  = var.fake_service_b_count
  subnet_id              = module.vpc.public_subnets[0]
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.consul-client-b-sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_role.consul-join.name
  tags = {
    Name      = "Consul-Client-Fake-Service-b"
    consul    = "client"
    auto-join = "yes"
  }

  // Connection to ec2
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.key_path}/${var.key_name}.pem")
  }


  // Upload Consul common config files to ec2_instance
  provisioner "file" {
    source      = "./user-data/consul-common"
    destination = var.destination_path
  }

  // upload fake-service-A.hcl registration config to ec2_instance
  provisioner "file" {
    source      = "./user-data/fake-service-b"
    destination = var.destination_path
  }

  user_data = file("./user-data/fake-service-b/install-fake-service-b.sh")

  /*****
  // upload CA-Cert to ec2_instance
  provisioner "file" {
    source      = "./user-data/certs/ca-cert.pem"
    destination = "/home/ubuntu/ca-cert.pem"
  }

  // upload Server-Cert to ec2_instance
  provisioner "file" {
    source      = "./user-data/certs/consul-server-cert.pem"
    destination = "/home/ubuntu/consul-server-cert.pem"
  }

  // upload Server-Key to ec2_instance
  provisioner "file" {
    source      = "./user-data/certs/consul-server-key.pem"
    destination = "/home/ubuntu/consul-server-key.pem"
  }
*******/

}

resource "aws_security_group" "consul-client-b-sg" {
  name        = "allow-fake-service-b-traffic"
  description = "Allow fake-service-b related inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Traffic to fake-service-B Consul sidecar on port 21000"
    from_port   = 21000
    to_port     = 21000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Traffic to fake-service-B on port 9092"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ssh_from_ip}/32"]
  }

  ingress {
    description = "Consul UI http"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ssh_from_ip}/32"]
  }

  ingress {
    description = "Consul UI https"
    from_port   = 8502
    to_port     = 8502
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ssh_from_ip}/32"]
  }

  ingress {
    description = "Consul 8300 - RPC"
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "Consul 8301 - LAN Serf"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
