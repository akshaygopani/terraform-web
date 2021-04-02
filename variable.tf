variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "vpc_azs" {
  type    = list(any)
  default = ["ap-south-1a", "ap-south-1b"]
}
variable "vpc_private_subnets" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "vpc_public_subnets" {
  type    = list(any)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}
variable "vpc_dns_hostname" {
  type    = bool
  default = true
}
variable "vpc_dns_support" {
  type    = bool
  default = true
}
variable "mysql_user" {
  type    = string
  default = "flask"
}
variable "mysql_password" {
  type    = string
  default = "crudflask987"
}
variable "mysql_database" {
  type    = string
  default = "crud"
}
variable "app_port" {
  type    = string
  default = "80"
}
variable "database_port" {
  type    = string
  default = "3306"
}
variable "clustername" {
  type    = string
  default = "wb-ecs"
}
variable "autoscale_targetvalue" {
  type    = number
  default = 80
}
variable "autoscale_metric_type" {
  type    = string
  default = "ECSServiceAverageMemoryUtilization"
}
variable "autoscale_policy_type" {
  type    = string
  default = "TargetTrackingScaling"
}
variable "container_name" {
  type    = string
  default = "first"
}
variable "container_port" {
  type    = number
  default = 80
}
variable "host_port" {
  type    = number
  default = 80
}
variable "ecs_launch_type" {
  type    = string
  default = "EC2"
}
variable "container_image" {
  type    = string
  default = "public.ecr.aws/w6s1v6p3/flask-ecr"
}
variable "db_engine" {
  type    = string
  default = "mysql"
}
variable "db_engine_version" {
  type    = string
  default = "8.0.20"
}
variable "db_engine_family" {
  type    = string
  default = "mysql8.0"
}
variable "db_major_engine_version" {
  type    = string
  default = "8.0"
}
variable "db_instance_type" {
  type    = string
  default = "db.t2.micro"
}
variable "db_name" {
  type    = string
  default = "crud"
}
variable "db_user_name" {
  type    = string
  default = "flask"
}
variable "db_user_password" {
  type      = string
  sensitive = true
  default   = "crudflask987"
}
variable "db_port" {
  type    = string
  default = "3306"
}
variable "db_storage_type" {
  type    = string
  default = "gp2"
}
variable "db_az" {
  type    = string
  default = "ap-south-1a"
}
variable "instance_ami" {
  type    = string
  default = "ami-036eaa870decb368d"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "instance_ebs_type" {
  type    = string
  default = "gp2"
}
variable "instance_ebs_size" {
  type    = number
  default = 10
}
variable "instance_root_size" {
  type    = number
  default = 30
}
variable "key_name" {
  type    = string
  default = "ec2-key"
}
variable "container_cpu_count" {
  type    = number
  default = 1
}
variable "container_memory" {
  type        = number
  description = "define memory in MB"
  default     = 568
}
variable "db_maintance_time" {
  type    = string
  default = "Mon:00:00-Mon:03:00"
}
variable "db_backup_time" {
  type    = string
  default = "03:15-06:00"
}
variable "db_storage" {
  type    = number
  default = 5
}
variable "db_max_storage" {
  type    = number
  default = 10
}
variable "sg_db_ingress" {
  type = list(any)
  default = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    },
  ]

}
variable "sg_web_ingress" {
  type = list(any)
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
  }, ]
}
variable "sg_web_egress" {
  type = list(any)
  default = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
variable "lb_type" {
  type    = string
  default = "application"
}
