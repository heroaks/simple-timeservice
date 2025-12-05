variable "aws_region" {
	type = string
	description = "AWS Region"
	default = "ap-south-1"
}

variable "project_name" {
	type = string
	description = "Project name"
	default = "simple-timeservice"
}

variable "container_image" {
	type = string
	description = "Docker image to deploy"
}

variable "container_port" {
	type = number
	default = 9000
}


