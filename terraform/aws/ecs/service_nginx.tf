resource "aws_ecs_service" "service_nginx" {
  name                 = "service_nginx"
  cluster              = aws_ecs_cluster.aws_ecs_cluster.id
  launch_type          = "EC2"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true
  task_definition      = "${aws_ecs_task_definition.task_nginx.family}:${max(aws_ecs_task_definition.task_nginx.revision, data.aws_ecs_task_definition.task_nginx_revision.revision)}"
  lifecycle {
    ignore_changes = [desired_count]
  }
}

data "aws_ecs_task_definition" "task_nginx_revision" {
  task_definition = aws_ecs_task_definition.task_nginx.family
}

resource "aws_ecs_task_definition" "task_nginx" {
  family                = "nginx-example"
  container_definitions = file("task_definitions/nginx_example.json")
  execution_role_arn    = var.ecs_role
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
}
