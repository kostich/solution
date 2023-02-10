resource "aws_ecs_task_definition" "task_definition" {
  family = "${var.environment}-task-definition"
  container_definitions = jsonencode([
    {
      name    = "${var.environment}-${var.app_name}"
      command = ["/app/test-app"]
      environment = [
        {
          name  = "HTTP_PORT"
          value = tostring(var.http_port)
        }
      ]
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.http_port
          hostPort      = var.http_port
        },
        {
          containerPort = var.grpc_port
          hostPort      = var.grpc_port
        }
      ]
      healthCheckPath = "/healthz"
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
}

resource "aws_ecs_service" "service" {
  name          = "${var.environment}-${var.app_name}"
  cluster       = aws_ecs_cluster.ecs_cluster.name
  desired_count = var.desired_count
  launch_type   = "FARGATE"

  task_definition = aws_ecs_task_definition.task_definition.arn

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    security_groups  = [aws_security_group.app_sg.id]
    subnets          = [aws_subnet.app_primary.id, aws_subnet.app_secondary.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "${var.environment}-${var.app_name}"
    container_port   = var.http_port
  }

  depends_on = [
    aws_lb_target_group.alb_tg,
    aws_lb_listener.alb_listener_http,
    aws_lb_listener.alb_listener_grpc
  ]
}