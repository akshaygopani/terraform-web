locals {
  vpc_id    = module.vpc.vpc_id
  db_sg_id  = module.db_server_sg.this_security_group_id
  web_sg_id = module.web_server_sg.this_security_group_id
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_dns_hostnames = var.vpc_dns_hostname
  enable_dns_support   = var.vpc_dns_support

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "db_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "db-service"
  description = "Security group for database access within vpc"
  vpc_id      = local.vpc_id
  ingress_with_cidr_blocks = [
    for ingress in var.sg_db_ingress :
    {
      from_port   = ingress.from_port
      to_port     = ingress.to_port
      protocol    = ingress.protocol
      cidr_blocks = ingress.cidr_blocks
    }
  ]
}
module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-service"
  description = "Security group for web access"
  vpc_id      = local.vpc_id


  ingress_with_cidr_blocks = [
    for ingress in var.sg_web_ingress :
    {
      from_port   = ingress.from_port
      to_port     = ingress.to_port
      protocol    = ingress.protocol
      cidr_blocks = ingress.cidr_blocks
    }
  ]
  egress_with_cidr_blocks = [
    for egress in var.sg_web_egress :
    {
      from_port   = egress.from_port
      to_port     = egress.to_port
      protocol    = egress.protocol
      cidr_blocks = egress.cidr_blocks
    }
  ]
}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  name               = "my-alb"
  load_balancer_type = var.lb_type
  vpc_id             = local.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [local.db_sg_id]
  target_groups = [
    {
      name_prefix      = "tg-ecs"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  http_tcp_listeners = [{
    port               = 80
    protocol           = "HTTP"
    target_group_index = 0
    }
  ]
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "service"

  # Launch configuration
  lc_name = "example-lc"

  image_id             = var.instance_ami
  instance_type        = var.instance_type
  security_groups      = [local.web_sg_id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=flask-web >> /etc/ecs/ecs.config"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  key_name             = var.key_name
  target_group_arns    = module.alb.target_group_arns
  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = var.instance_ebs_type
      volume_size           = var.instance_ebs_size
      delete_on_termination = true
    },
  ]
  root_block_device = [
    {
      volume_size = var.instance_root_size
      volume_type = var.instance_ebs_type
    },
  ]

  # Auto scaling group
  asg_name                  = "example-asg"
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"


  identifier           = "mysql-flask"
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  family               = var.db_engine_family
  major_engine_version = var.db_major_engine_version

  instance_class        = var.db_instance_type
  allocated_storage     = var.db_storage
  max_allocated_storage = var.db_max_storage
  storage_type          = var.db_storage_type

  name     = var.db_name
  username = var.db_user_name
  password = var.db_user_password
  port     = var.db_port

  multi_az               = false
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.db_server_sg.this_security_group_id]

  maintenance_window = var.db_maintance_time
  backup_window      = var.db_backup_time


  availability_zone       = var.db_az
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Owner       = "flask"
    Environment = "dev"
  }
}


resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}
resource "aws_ecs_task_definition" "web_task" {
  family                   = "web-task"
  requires_compatibilities = toset([var.ecs_launch_type])

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = var.container_cpu_count
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
      environment = [{
        "name"  = "MYSQL_USER",
        "value" = var.mysql_user
        },
        { "name"  = "MYSQL_PASSWORD",
          "value" = var.mysql_password
        },
        { "name"  = "MYSQL_DATABASE",
          "value" = var.mysql_database
        },
        { "name"  = "APP_PORT",
          "value" = var.app_port
        },
        { "name"  = "DATABASE_IP",
          "value" = module.db.this_db_instance_address
        },
        {
          "name"  = "DATABASE_URL"
          "value" = "mysql+pymysql://${var.mysql_user}:${var.mysql_password}@${module.db.this_db_instance_address}:${var.database_port}/${var.mysql_database}",
        },
      ]
    },
  ])
}
resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.flask_ecs.arn
  desired_count   = 1
  task_definition = aws_ecs_task_definition.web_task.arn
  launch_type     = var.ecs_launch_type
  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.flask_ecs.name}/${aws_ecs_service.web_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-in-out"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  policy_type        = var.autoscale_policy_type
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.autoscale_metric_type
    }
    target_value       = var.autoscale_targetvalue
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_ecs_cluster" "flask_ecs" {
  name = var.clustername
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

