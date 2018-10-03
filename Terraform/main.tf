terraform {
  backend "s3" {
    bucket = "terraform.state.microservices.net"
    key    = "state.tfstate"
    region = "us-west-2"
  }
}

### NETWORKING ==========================================================

provider "aws" {
  region = "${var.aws_region}"
}

### Network

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

data "aws_ami" "nat_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "${terraform.workspace == "prod" ? var.vpc_cidr_prod : var.vpc_cidr_staging}"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${terraform.workspace}"
  }
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
}

# IGW for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = "${var.az_count}"
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_instance" "nat" {
  ami                         = "${data.aws_ami.nat_ami.id}"
  availability_zone           = "${data.aws_availability_zones.available.names[0]}"
  instance_type               = "t2.micro"
  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, 0)}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "VPC NAT"
  }
}

# Create a new route table for the private subnets
# And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
}

# Explicitely associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

### Security

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "tf-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nat" {
  name        = "tf-nat"
  description = "controls access to the NAT instance"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr_prod}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${terraform.workspace}-tf-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  ingress {
    protocol = -1
    from_port = 0
    to_port = 0
    self = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### ALB ==========================================================

resource "aws_alb" "main" {
  name            = "${terraform.workspace}-tf-ecs"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "app_1" {
  name        = "${terraform.workspace}-tf-ecs-1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"
  health_check {
    path = "/healthcheck"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_listner1" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app_1.id}"
    type             = "forward"
  }
}

resource "aws_route53_record" "cname_route53_record" {
  zone_id = "${var.r53_zoneid}"
  name    = "${terraform.workspace == "prod" ? var.dns_prod_subdomain : var.dns_staging_subdomain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.main.dns_name}"
    zone_id                = "${aws_alb.main.zone_id}"
    evaluate_target_health = true
  }
}

### ECS CLUSTER ==========================================================

resource "aws_service_discovery_private_dns_namespace" "microservices" {
  name        = "${var.aws_service_discovery_namespace_name}"
  description = "store2018"
  vpc         = "${aws_vpc.main.id}"
}

resource "aws_ecs_cluster" "main" {
  name = "${terraform.workspace}-tf-ecs-cluster"
}

### MICROSERVICE AccountService ==========================================================

resource "aws_ecs_task_definition" "api-account" {
  family                   = "${terraform.workspace}-api-account"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image_accountservice}",
    "memory": ${var.fargate_memory},
    "name": "${terraform.workspace}-api-account",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_service_discovery_service" "api-account" {
  name = "api-account"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.microservices.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

resource "aws_ecs_service" "service-account" {
  name            = "${terraform.workspace}-tf-ecs-service-account"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.api-account.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.api-account.arn}"
  }  
}

### MICROSERVICE InventoryService ==========================================================

resource "aws_ecs_task_definition" "api-inventory" {
  family                   = "${terraform.workspace}-api-inventory"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image_inventoryservice}",
    "memory": ${var.fargate_memory},
    "name": "${terraform.workspace}-api-inventory",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_service_discovery_service" "api-inventory" {
  name = "api-inventory"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.microservices.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

resource "aws_ecs_service" "service-inventory" {
  name            = "${terraform.workspace}-tf-ecs-service-inventory"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.api-inventory.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.api-inventory.arn}"
  }
}

### MICROSERVICE ShoppingService ==========================================================

resource "aws_ecs_task_definition" "api-shopping" {
  family                   = "${terraform.workspace}-api-shopping"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image_shoppingservice}",
    "memory": ${var.fargate_memory},
    "name": "${terraform.workspace}-api-shopping",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_service_discovery_service" "api-shopping" {
  name = "api-shopping"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.microservices.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

resource "aws_ecs_service" "service-shopping" {
  name            = "${terraform.workspace}-tf-ecs-service-shopping"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.api-shopping.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.api-shopping.arn}"
  }
}

### MICROSERVICE Store2018 ==========================================================

resource "aws_ecs_task_definition" "app-store2018" {
  family                   = "${terraform.workspace}-app-store2018"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image_store2018}",
    "memory": ${var.fargate_memory},
    "name": "${terraform.workspace}-app-store2018",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
        {
            "name": "ACCOUNT_SERVICE_API_BASE",
            "value": "http://api-account.${var.aws_service_discovery_namespace_name}/api"
        },
        {
            "name": "INVENTORY_SERVICE_API_BASE",
            "value": "http://api-inventory.${var.aws_service_discovery_namespace_name}/api"
        },
        {
            "name": "SHOPPING_SERVICE_API_BASE",
            "value": "http://api-shopping.${var.aws_service_discovery_namespace_name}/api"
        }                
    ]    
  }
]
DEFINITION
}

resource "aws_service_discovery_service" "app-store2018" {
  name = "app-store2018"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.microservices.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

resource "aws_ecs_service" "service-store2018" {
  name            = "${terraform.workspace}-tf-ecs-service-store2018"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app-store2018.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.app-store2018.arn}"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app_1.id}"
    container_name   = "${terraform.workspace}-app-store2018"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_alb_listener.front_end_listner1"
  ]  
}