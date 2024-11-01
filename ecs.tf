
# ECS Task Definition with 2 containers
resource "aws_ecs_task_definition" "task_definition_app" {
  family                   = "app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "webapp"
      image     = "${aws_ecr_repository.ecr_repo_webapp.repository_url}:latest"
      essential = true
      portMappings = [
        {
          "name" : "webapp",
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ]
      environment : [
        {
          "name" : "MYSQL_DATABASE",
          "value" : "myapp"
        },
        {
          "name" : "MYSQL_PASSWORD",
          "value" : "myapp"
        },
        {
          "name" : "MYSQL_HOST",
          "value" : "0.0.0.0"
        },
        {
          "name" : "MYSQL_USER",
          "value" : "myapp"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app"
          awslogs-region        = var.region
          awslogs-stream-prefix = "app"
        }
      }
    },
    {
      name      = "mysql"
      image     = "${aws_ecr_repository.ecr_repo_mysql.repository_url}:latest"
      essential = true
      portMappings = [
        {
          "name" : "mysql",
          "containerPort" : 3306,
          "hostPort" : 3306,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      environment : [
        {
          "name" : "MYSQL_DATABASE",
          "value" : "myapp"
        },
        {
          "name" : "MYSQL_PASSWORD",
          "value" : "myapp"
        },
        {
          "name" : "MYSQL_ROOT_PASSWORD",
          "value" : "root"
        },
        {
          "name" : "MYSQL_USER",
          "value" : "myapp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/mysql"
          awslogs-region        = var.region
          awslogs-stream-prefix = "mysql"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ECS Cluster
resource "aws_ecs_cluster" "cluster_main" {
  name = "app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = "/ecs/cluster"
      }
    }
  }

  tags = {
    Name = "app-cluster"
  }
}




# # Private Subnets
# resource "aws_subnet" "private" {
#   count             = 2
#   vpc_id            = aws_vpc.tamnt1-vpc.id
#   cidr_block        = "10.0.${count.index + 1}.0/24"
#   availability_zone = data.aws_availability_zones.available.names[count.index]

#   tags = {
#     Name = "Private Subnet ${count.index + 1}"
#   }
# }

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.cluster_main.id
  task_definition = aws_ecs_task_definition.task_definition_app.arn
  desired_count   = 1
  launch_type     = var.esc_launch_type

  network_configuration {
    subnets          = [aws_subnet.public_subnet_us-east-2a, aws_subnet.public_subnet_us-east-2b]
    security_groups  = [aws_security_group.private_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "webapp"
    container_port   = 80
  }
}

