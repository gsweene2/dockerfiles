provider "aws" {
  region = "us-west-1"
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

resource "aws_vpc_ipv4_cidr_block_association" "terra_ingress_subnet_az_1" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_vpc_ipv4_cidr_block_association" "terra_ingress_subnet_az_2" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

resource "aws_vpc_ipv4_cidr_block_association" "terra_private_subnet" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_vpc_ipv4_cidr_block_association" "terra_private_subnet" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

resource "aws_vpc_ipv4_cidr_block_association" "terra_data_subnet" {
  vpc_id     = "${aws_vpc.terra_vpc.id}"
  cidr_block = "10.0.4.0/24"
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
}

resource "aws_lb" "terra-alb" {
  name               = "garretts-terra-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_all.id}"]
  subnets            = ["${aws_subnet.terra_ingress_subnet_az_1.*.id}"]

  enable_deletion_protection = true

  access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
  route_table_id = "${aws_route_table.r.id}"
}

## Compute

resource "aws_placement_group" "terra-pg" {
  name     = "test"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "terra-app-asg" {
  name                      = "garretts-terra-app-asg"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  placement_group           = "${aws_placement_group.terra-pg.id}"
  launch_configuration      = "${aws_launch_configuration.terra-lc.name}"
  vpc_zone_identifier       = ["${aws_subnet.terra_private_subnet.id}", "${aws_subnet.terra_private_subnet.id}"]

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

}