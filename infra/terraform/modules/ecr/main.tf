#=============
# Input Value
#=============
// ECS，EC2 Instance
variable "instance_app_name" {}

#==============
# ECR
#==============
resource "aws_ecr_repository" "ecr_repository_builder" {
  name                 = "${var.instance_app_name}-builder-ecr-respository"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "ecr_repository_www" {
  name                 = "${var.instance_app_name}-www-ecr-respository"
  image_tag_mutability = "MUTABLE"
}