variable "region" {
  default = "us-east-2"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}


variable "availability_zone" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b"]
}

variable "subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "amis" {
  type    = string
  default = "ami-0374badf0de443688"
}



variable "instance_type" {
  type    = string
  default = "t2.micro"
}