# Create Consul Servers
resource "aws_instance" "consul-server" {
  depends_on = [ module.vpc ]
  count = var.consul_server_count
  subnet_id              = module.vpc.public_subnets[0]
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.consul-server-sg.id]
  iam_instance_profile = aws_iam_role.consul-join.name
  tags = {
    Name      = "Consul-Server"
    consul    = "server"
    auto-join = "yes"
  }

  // Connection to ec2
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.key_path}/${var.key_name}.pem")
  }

##  // Upload Consul common config files to ec2_instance
##  provisioner "file" {
##    source      = "./user-data/consul-common"
##    destination = var.destination_path
##  }

  // upload Consul config files to ec2_instance
  // Files include:
  // 1. consul-server.hcl
  // 2. consul.service
  provisioner "file" {
    source      = "./user-data/consul-server"
    destination = var.destination_path
  }

  user_data = file("./user-data/consul-server/install-consul-server.sh")

  /********
  // upload CA-Cert to ec2_instance
  provisioner "file" {
    source      = "./user-data/certs/ca-cert.pem"
    destination = "${local.destination_path}/ca-cert.pem"
  }

  // upload Server-Cert to ec2_instance
  provisioner "file" {
    source      = "./user-data/certs/consul-server-cert.pem"
    destination = "${local.destination_path}/consul-server-cert.pem"
  }

  // upload Server-Key to ec2_instance
  provisioner "file" {
    source      = "./user-data/certs/consul-server-key.pem"
    destination = "${local.destination_path}/consul-server-key.pem"
  }
***************************************************************/
}

# Create Security Group for Consul Servers
resource "aws_security_group" "consul-server-sg" {
  name        = "allow-consul-server-traffic"
  description = "Allow Consul related inbound traffic"
  vpc_id = module.vpc.vpc_id
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

### Consul Cloud Auto Join IAM role & policy
# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "consul-join"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("./templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name = "consul-join"
  role = aws_iam_role.consul-join.name
}