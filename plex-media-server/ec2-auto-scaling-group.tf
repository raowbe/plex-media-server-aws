resource "aws_autoscaling_group" "plex" {
  name = "${var.environment}-plex"

  availability_zones   = [var.availability_zone]
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.plex.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_types
        content {
            instance_type = override.value
        }
      }
    }

    instances_distribution {
      on_demand_percentage_above_base_capacity = var.spot ? 0 : 100
      spot_allocation_strategy                 = "lowest-price"
    }
  }
}
