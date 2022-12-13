resource "aws_placement_group" "this" {
  name     = "wordpress"
  strategy = "cluster"

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-wordpress"
    }
  )
}

#Define o grupo do autoscaling para trabalhar nas AZs A e B, e seu comportamento
resource "aws_autoscaling_group" "this" {
  name                = "wordpress"
  desired_capacity    = 4
  max_size            = 8
  min_size            = 4
  vpc_zone_identifier = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]

  target_group_arns = [
    aws_lb_target_group.http.arn,
  ]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

#Define a política de criação de novas instâncias do Wordpress. Quando a soma do processamento das instâncias disponíveis alcançar 50%, o autoscaling sobe mais instâncias
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