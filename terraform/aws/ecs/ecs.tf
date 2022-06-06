resource "aws_ecs_cluster" "aws_ecs_cluster" {
  name = "${var.env_name}-cluster"
}
