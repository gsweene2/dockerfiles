provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "example" {
  ami = "ami-0bdb828fd58c52235"
  instance_type = "t2.micro"
  subnet_id = "subnet-23fadd78"
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              export PASSWORD='aws secretsmanager get-secret-value --secret-id garretts-example-secret-key --region us-west-1'
              touch ~/myPASSWORD.txt
              echo PASSWORD > ~/myPASSWORD.txt
              EOF
  key_name = "my-terraform-keypair"
  security_groups = ["sg-007d6e572cb472e69"]
  tags {
    Name = "garrett terraform instance"
  }
}