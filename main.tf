terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}

provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "sva-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "sva-terraform-locks"
    encrypt        = true
  }
}

data "aws_ami" "sva_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_lb" "sva_lb" {

  name               = "sva-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sva_alb_sg.id]
  subnets            = [aws_subnet.private_sbn_1a.id, aws_subnet.private_sbn_1b.id]

}

resource "aws_lb_target_group" "sva_tg" {

  name     = "sva-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sva_task_vpc.id
  # provider = aws.us_east_1

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
  }

  tags = {
    Name             = "sva_task"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}

resource "aws_lb_listener" "sva_listener" {

  load_balancer_arn = aws_lb.sva_lb.arn
  port              = 80
  protocol          = "HTTP"
  # provider          = aws.us_east_1

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sva_tg.arn
  }

  tags = {
    Name             = "sva_task"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}


resource "aws_security_group" "sva_alb_sg" {
  name        = "alb-sg"
  description = "Connect Web UI"
  vpc_id      = aws_vpc.sva_task_vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name             = "sva_security-group"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}


resource "aws_ssm_parameter" "sva_secret" {
  name        = "/APP_SECRET"
  description = "Connect Web UI APP_SECRET"
  type        = "SecureString"
  value       = var.sva_secret
  tags = {
    Name             = "sva_secret"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}

resource "aws_autoscaling_group" "sva_asg" {
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [aws_subnet.private_sbn_1a.id]
  target_group_arns   = [aws_lb_target_group.sva_tg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.sva_dev.id
    version = "$Latest"
  }


  tag {
    key                 = "Name"
    value               = "sva_vm_instance"
    propagate_at_launch = true
  }


  tag {
    key                 = "Environment"
    value               = "developement"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cost_Center"
    value               = "web-system-sva"
    propagate_at_launch = true
  }
  tag {
    key                 = "Cost_Center_Code"
    value               = "0001"
    propagate_at_launch = true
  }
  tag {
    key                 = "Service_Name"
    value               = "web-api-sva"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "dev_sva_ntsikelelo_metseeme"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "sva_dev" {

  name_prefix   = "sva_vm_"
  image_id      = data.aws_ami.sva_ubuntu.id
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.sva_profile.name
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.sva_alb_sg.id]
  }


  tags = {
    Name             = "sva_vm_instance"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_internet_gateway" "sva_igw" {
  vpc_id = aws_vpc.sva_task_vpc.id


  tags = {
    Name             = "sva_igw"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}
# resource "aws_route_table" "sva_public" {
#   vpc_id = aws_vpc.sva_task_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.sva_igw.id
#   }
# }

# resource "aws_route_table_association" "sva_public" {
#   subnet_id      = aws_subnet.sva_public.id
#   route_table_id = aws_route_table.sva_public.id
# }

