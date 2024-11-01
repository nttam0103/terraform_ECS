# Thay đổi các thông số sau theo yêu cầu 
region = "us-east-2"

instance_type = "t2.micro"
amis          = "ami-0374badf0de443688"

esc_launch_type = "FARGATE"

ecr_account_id = "302263063173"

docker_image_mysql  = "854108365735.dkr.ecr.us-east-2.amazonaws.com/mysql"
docker_image_webapp = "854108365735.dkr.ecr.us-east-2.amazonaws.com/web-app"

docker_tag = "latest"

