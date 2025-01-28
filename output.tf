## Consul Server UI
output "consul-ui" {
  value = "${aws_instance.consul-server[0].public_dns}:8500"
}

## ssh into Consul Server
output "ssh-consul-server-nodes" {
  #value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.consul-server[0].public_dns}"
  value = try([for i in aws_instance.consul-server : "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${i.public_dns}"])
}

## ssh into fake-service-a nodes
output "ssh-fake-service-a-nodes" {
  value = try([for i in aws_instance.consul-client-a : "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${i.public_dns}"])
}

## ssh into fake-service-b nodes
output "ssh-fake-service-b-nodes" {
  value = try([for i in aws_instance.consul-client-b : "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${i.public_dns}"])
}

## ssh into consul-api-gateway nodes
output "ssh-api-gateway-nodes" {
  value = try([for i in aws_instance.consul-api-gateway : "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${i.public_dns}"])
}

## Consul API Gateway UI
output "consul-api-gateway-ui" {
  value = try([for i in aws_instance.consul-api-gateway : "${i.public_dns}:8443"])
}
