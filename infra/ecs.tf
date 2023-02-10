resource "aws_kms_key" "kms_key" {
  description             = "${var.environment}-kms-key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "cloudwatch_group" {
  name = "${var.environment}-cloudwatch-group"
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-ecs-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kms_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cloudwatch_group.name
      }
    }
  }
}

