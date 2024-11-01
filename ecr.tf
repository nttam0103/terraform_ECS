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


resource "null_resource" "erc_login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.ecr_account_id}.dkr.ecr.us-east-2.amazonaws.com"
  }
}

resource "null_resource" "ecr_tag_mysql" {
  depends_on = [null_resource.erc_login]
  provisioner "local-exec" {

    command = "docker tag ${var.docker_image_mysql}:${var.docker_tag} ${var.ecr_account_id}.dkr.ecr.us-east-2.amazonaws.com/erc_repo_mysql.name:${var.docker_tag}"
  }
}

resource "null_resource" "ecr_push_mysql" {
  depends_on = [null_resource.ecr_tag_mysql]
  provisioner "local-exec" {
    command = "docker push ${var.ecr_account_id}.dkr.ecr.${var.region}.amazonaws.com/erc_repo_mysql.name:${var.docker_tag}"
  }
}

resource "null_resource" "ecr_tag_webapp" {
  depends_on = [null_resource.erc_login]
  provisioner "local-exec" {

    command = "docker tag ${var.docker_image_webapp}:${var.docker_tag} ${var.ecr_account_id}.dkr.ecr.us-east-2.amazonaws.com/ecr_repo_webapp.name:${var.docker_tag}"
  }
}

resource "null_resource" "ecr_push_webapp" {
  depends_on = [null_resource.ecr_tag_mysql]
  provisioner "local-exec" {
    command = "docker push ${var.ecr_account_id}.dkr.ecr.${var.region}.amazonaws.com/$ecr_repo_webapp.name:${var.docker_tag}"
  }
}