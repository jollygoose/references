resource "aws_launch_template" "ecs_template" {
  name_prefix   = "ecs"
  image_id      = var.AMI
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = "true"
      volume_size = 30
    }
  }

  instance_market_options {
    market_type = "spot"
  }

  placement {
    availability_zone = var.availability_zone_1
  }
  key_name  = var.key_name
  user_data = base64encode(data.template_file.script.rendered)

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
  ]

  iam_instance_profile {
    name = var.instance_role
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity      = 1
  max_size              = 1
  min_size              = 1
  vpc_zone_identifier   = [aws_subnet.subnet_public_1.id]
  protect_from_scale_in = true
  launch_template {
    id      = aws_launch_template.ecs_template.id
    version = "$Latest"
  }
}

data "template_file" "script" {
  template = file("script.tpl")
  vars = {
    cluster_name = "${aws_ecs_cluster.aws_ecs_cluster.name}"
  }
}
