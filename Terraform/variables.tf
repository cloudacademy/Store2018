variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "aws_key_name" {
  default = "KEYNAME_GOES_HERE"
}

variable "aws_service_discovery_namespace_name" {
  default="microservices.private"
}

variable "r53_zoneid" {
  default = "R53_ZONE_ID_GOES_HERE"
}

variable "dns_prod_subdomain" {
  default = "store2018"
}

variable "dns_staging_subdomain" {
  default = "store2018test"
}

variable "vpc_cidr_prod" {
  default = "192.168.0.0/16"
}

variable "vpc_cidr_staging" {
  default = "172.17.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "app_image_accountservice" {
  description = "Account Service docker image to run in the ECS cluster"
  default     = "jeremycookdev/accountservice:latest"
}

variable "app_image_inventoryservice" {
  description = "Inventory Service docker image to run in the ECS cluster"
  default     = "jeremycookdev/inventoryservice:latest"
}

variable "app_image_shoppingservice" {
  description = "Shopping Service docker image to run in the ECS cluster"
  default     = "jeremycookdev/shoppingservice:latest"
}

variable "app_image_store2018" {
  description = "Store2018 App UI docker image to run in the ECS cluster"
  default     = "jeremycookdev/store2018:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}
