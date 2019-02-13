provider "aws" {
  region = "us-west-2"
}

## Network

resource "aws_vpc" "terra_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags = {
    Name = "main"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "terra_ingress_subnet_az_1" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_subnet" "terra_ingress_subnet_az_2" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_subnet" "terra_private_subnet_az_1" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_subnet" "terra_private_subnet_az_2" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_subnet" "terra_data_subnet_az_1" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-west-2a"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_subnet" "terra_data_subnet_az_2" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-west-2b"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id     = "${aws_vpc.terra_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_security_group" "terra_instance_sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id     = "${aws_vpc.terra_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "garrett-my-tf-test-bucket"
  acl    = "public"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_alb_target_group" "terra_alb_target_group" {
  name     = "garrett-terra-alb-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.terra_vpc.id}"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_alb" "terra_alb" {
  name               = "garretts-terra-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_all.id}"]
  subnets            = ["${aws_subnet.terra_ingress_subnet_az_1.id}","${aws_subnet.terra_ingress_subnet_az_2.id}"]

  enable_deletion_protection = true

  access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }

  depends_on = [
    "aws_security_group.allow_all",
    "aws_subnet.terra_ingress_subnet_az_1",
    "aws_subnet.terra_ingress_subnet_az_2",
    "aws_s3_bucket.lb_logs"
  ]
}

resource "aws_alb_listener" "terra_alb_listener" {
  load_balancer_arn = "${aws_alb.terra_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.terra_alb_target_group.id}"
    type             = "forward"
  }

  depends_on = [
    "aws_alb.terra_alb",
    "aws_alb_target_group.terra_alb_target_group"
  ]
}

resource "aws_internet_gateway" "terra_gw" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  depends_on = [
    "aws_vpc.terra_vpc"
  ]
}

resource "aws_route_table" "terra_route_table" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_gw.id}"
  }

  depends_on = [
    "aws_vpc.terra_vpc",
    "aws_internet_gateway.terra_gw"
  ]
}

resource "aws_route_table_association" "terra_route_table_assoc_az_1" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_ingress_subnet_az_1.id}"
  route_table_id = "${aws_route_table.terra_route_table.id}"

  depends_on = [
    "aws_subnet.terra_ingress_subnet_az_1",
    "aws_route_table.terra_route_table",
  ]
}

resource "aws_route_table_association" "terra_route_table_assoc_az_2" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_ingress_subnet_az_2.id}"
  route_table_id = "${aws_route_table.terra_route_table.id}"

  depends_on = [
    "aws_subnet.terra_ingress_subnet_az_2",
    "aws_route_table.terra_route_table"
  ]
}

## Compute

resource "aws_placement_group" "terra-pg" {
  name     = "test"
  strategy = "cluster"
}

data "aws_ami" "basic_ubuntu" {
  most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_iam_instance_profile" "app" {
  name = "tf-ecs-instprofile"
  role = "${aws_iam_role.terra_app_instance.name}"

  depends_on = [
    "aws_iam_role.terra_app_instance"
  ]
}

resource "aws_iam_role" "terra_app_instance" {
  name = "garrett-terra-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_launch_configuration" "terra_lc" {
  security_groups = [
    "${aws_security_group.terra_instance_sg.id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.basic_ubuntu.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  user_data                   = "${data.template_file.cloud_config.rendered}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_iam_instance_profile.app"
  ]
}

resource "aws_autoscaling_group" "terra-app-asg_az_1" {
  name                      = "garretts-terra-app-asg"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  placement_group           = "${aws_placement_group.terra-pg.id}"
  launch_configuration      = "${aws_launch_configuration.terra_lc.name}"
  vpc_zone_identifier       = ["${aws_subnet.terra_ingress_subnet_az_1.id}"]
  target_group_arns         = ["${aws_alb_target_group.terra_alb_target_group.id}"]

  initial_lifecycle_hook {
    name                 = "terra-lifecycle-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "from"
    value               = "terraform"
    propagate_at_launch = true
  }

  depends_on = [
    "aws_placement_group.terra-pg",
    "aws_launch_configuration.terra_lc",
    "aws_subnet.terra_ingress_subnet_az_1",
    "aws_alb_target_group.terra_alb_target_group"
  ]

}

resource "aws_autoscaling_group" "terra-app-asg_az_2" {
  name                      = "garretts-terra-app-asg"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  placement_group           = "${aws_placement_group.terra-pg.id}"
  launch_configuration      = "${aws_launch_configuration.terra_lc.name}"
  vpc_zone_identifier       = ["${aws_subnet.terra_ingress_subnet_az_2.id}"]
  target_group_arns         = ["${aws_alb_target_group.terra_alb_target_group.id}"]

  initial_lifecycle_hook {
    name                 = "terra-lifecycle-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "from"
    value               = "terraform"
    propagate_at_launch = true
  }

  depends_on = [
    "aws_placement_group.terra-pg",
    "aws_launch_configuration.terra_lc",
    "aws_subnet.terra_ingress_subnet_az_2",
    "aws_alb_target_group.terra_alb_target_group"
  ]

}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars {
    aws_region         = "${var.aws_region}"
  }
}