# to check if the ami is correct - find it firsl and run terraform plan
output "ec2_public_ip" {
  value = module.myapp-server.instance.public_ip //aws_instance.my-server.public_ip
}