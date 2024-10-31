# ECR Private Registry cho MySQL
resource "aws_ecr_repository" "ecr_repo_mysql" {
  name                 = "my-sql"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  
}

# ECR Repository Policy cho MySQL
resource "aws_ecr_repository_policy" "ecr_policy_mysql" {
  repository = aws_ecr_repository.ecr_repo_mysql.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages"
        ]
      }
    ]
  })
}

# ECR Lifecycle Policy cho MySQL
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_mysql" {
  repository = aws_ecr_repository.ecr_repo_mysql.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repo_mysql_url" {
  value = aws_ecr_repository.ecr_repo_mysql.repository_url
}



# ECR Private Registry cho WebApp
resource "aws_ecr_repository" "ecr_repo_webapp" {
  name                 = "web-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  
}

# ECR Repository Policy cho WebApp
resource "aws_ecr_repository_policy" "ecr_policy_webapp" {
  repository = aws_ecr_repository.ecr_repo_webapp.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages"
        ]
      }
    ]
  })
}

# ECR Lifecycle Policy cho WebApp
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_webapp" {
  repository = aws_ecr_repository.ecr_repo_webapp.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repo_webapp_url" {
  value = aws_ecr_repository.ecr_repo_webapp.repository_url
}