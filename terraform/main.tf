module "vpc" {
	source = "terraform-aws-modules/vpc/aws"
	version = "~> 5.0"

	name = var.project_name
	cidr = "10.0.0.0/16"

	azs = ["ap-south-1a", "ap-south-1b"]
	private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
	public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

	enable_nat_gateway = true
	single_nat_gateway = true

	enable_dns_hostnames = true
	enable_dns_support = true
}

resource "aws_ecs_cluster" "this" {
  name = var.project_name
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name   = "${var.project_name}-ecs"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = var.project_name
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "this" {
  name        = var.project_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
      essential = true
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.project_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.project_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}

