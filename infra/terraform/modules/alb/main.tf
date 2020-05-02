#=============
# Input Value
#=============
// AWS認証情報
variable "region" {}

// VPC
variable "vpc_id" {}

// Subnet
variable "subnet_public_1a_id" {}
variable "subnet_public_1c_id" {}

// Security Group
variable "security_group_alb_id" {}

// EC2 Instance
variable "instance_app_name" {}

#==========================
# Application Load Balancer
#==========================
resource "aws_alb" "alb" {
  name = "${var.instance_app_name}-alb"
  security_groups = [var.security_group_alb_id]
  subnets = [var.subnet_public_1a_id, var.subnet_public_1c_id]
  
}

data "aws_lb_target_group" "test" {
  name = "${var.instance_app_name}-alb-target"
}