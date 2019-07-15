output "appautoscaling_scale_up_policy_arn" {
  value = element(concat(aws_appautoscaling_policy.scale_up.*.arn, list("")), 0)
}

output "appautoscaling_scale_down_policy_arn" {
  value = element(concat(aws_appautoscaling_policy.scale_down.*.arn, list("")), 0)
}
