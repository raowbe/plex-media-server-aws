resource "aws_autoscaling_notification" "plex" {
  group_names = [
    aws_autoscaling_group.plex.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_cloudformation_stack.sns_topic.outputs["ARN"]
}

resource "aws_cloudformation_stack" "sns_topic" {
  name          = "${var.environment}-sns-email-plex"
  template_body = templatefile("${path.module}/templates/sns-email.json", 
      { 
        display_name  = "${var.environment}-sns-email-plex"
        email_address = var.sns_email_address
        protocol      = "email"
      }
    )
}