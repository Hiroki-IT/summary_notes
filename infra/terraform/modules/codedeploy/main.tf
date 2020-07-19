#=============
# Input Value
#=============
// App Info
variable "app_name" {}

// ALB
variable "alb_target_group_blue_name" {}
variable "alb_target_group_green_name" {}
variable "alb_listener_blue_arn" {}

// ECS
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}

// CodeDeploy
variable "codedeployment_role_for_ecs_arn" {}

#=================
# CodeDeploy App
#=================
resource "aws_codedeploy_app" "codedeploy_app" {
  name             = var.app_name
  compute_platform = "ECS"
}

#===================
# CodeDeploy Group
#===================
resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name               = var.app_name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.app_name}-delpoyment-group"
  service_role_arn       = var.codedeployment_role_for_ecs_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_blue_arn]
      }

      target_group {
        name = var.alb_target_group_blue_name
      }

      target_group {
        name = var.alb_target_group_green_name
      }
    }
  }
}