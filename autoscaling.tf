resource "aws_placement_group" "this" {
  name     = "test"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "this" {
  name                = "autoscaling_desafio_final"
  desired_capacity    = 2
  max_size            = 8
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]

  target_group_arns = [
    aws_lb_target_group.http.arn,
  ]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  name                   = "50percentCPU"
  policy_type            = "PredictiveScaling"
  predictive_scaling_configuration {
    metric_specification {
      target_value = 50.0
      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label         = "testLabel"
      }
      customized_scaling_metric_specification {
        metric_data_queries {
          id = "scaling"
          metric_stat {
            metric {
              metric_name = "CPUUtilization"
              namespace   = "AWS/EC2"
              dimensions {
                name  = "this"
                value = "my-test-asg"
              }
            }
            stat = "Average"
          }
        }
      }
    }
  }
}