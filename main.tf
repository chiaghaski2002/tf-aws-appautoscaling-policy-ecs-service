variable "cluster_name" {
  type = "string"
}

variable "service_name" {
  type = "string"
}

variable "min_capacity" {
  type = "string"

  default = "0"
}

variable "max_capacity" {
  type = "string"

  default = "0"
}

variable "scale_up_cooldown" {
  default = "60"
}

variable "scale_down_cooldown" {
  default = "300"
}

variable "scale_up_adjustment" {
  default = "1"
}

variable "scale_down_adjustment" {
  default = "-1"
}

variable "resource_id" {
}

locals {
  compose_resource_id = "service/${var.cluster_name}/${var.service_name}"
}

resource "aws_appautoscaling_target" "this" {
  max_capacity = "${var.max_capacity}"
  min_capacity = "${var.min_capacity}"
  resource_id  = "${local.compose_resource_id}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "app-scale-up-${var.service_name}"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  policy_type        = "StepScaling" // DEFAULT VALUE

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.scale_up_cooldown}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = "${var.scale_up_adjustment}"
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "app-scale-down-${var.service_name}"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  policy_type        = "StepScaling" // DEFAULT VALUE

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.scale_down_cooldown}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = "${var.scale_down_adjustment}"
    }
  }
}
