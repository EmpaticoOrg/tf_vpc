variable "environment" {
  description = "The name of our environment, i.e. development."
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC."
}

variable "public_subnets" {
  default     = []
  description = "The list of public subnets to populate."
}

variable "private_subnets" {
  default     = []
  description = "The list of private subnets to populate."
}

variable "enable_dns_hostnames" {
  description = "Should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

output "vpc_id" {
  value = "${aws_vpc.environment.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.environment.cidr_block}"
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private.*.id}"]
}

output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "private_route_table_id" {
  value = "${aws_route_table.private.id}"
}

output "default_security_group_id" {
  value = "${aws_vpc.environment.default_security_group_id}"
}

output "riemann_security_group_id" {
  value = "${aws_security_group.riemann.id}"
}
