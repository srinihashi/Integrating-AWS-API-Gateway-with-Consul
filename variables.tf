variable "region" {
  description = "region"
  type        = string
  default     = "us-east-1"
}

variable "consul_server_count" {
  description = "consul_server_count"
  type        = number
  default     = 1
}

variable "ubuntu_ami" {
  description = "ami"
  type        = string
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "key_name"
  type        = string
  default     = "id_rsa"
}

variable "key_path" {
  description = "key_path"
  type        = string
  default     = "~/.ssh"
}

variable "allow_ssh_from_ip" {
  description = "allow_ssh_from_ip"
  type        = string
}

# Destination path on ec2_instances
variable "destination_path" {
  description = "destination_path on nodes for consul config files"
  type        = string
  default     = "/tmp"
}

# Fake Services instnace counts
variable "fake_service_a_count" {
  description = "# of fake-service-a instnaces"
  type        = number
  default     = 1
}

variable "fake_service_b_count" {
  description = "# of fake-service-b instnaces"
  type        = number
  default     = 1
}

variable "api-gateway_count" {
  description = "# of Consul api-gateway instnaces"
  type        = number
  default     = 1
}
