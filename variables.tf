variable "vpc_cidr_block" {
	description = "Top level CIDR block for VPC"
	default     = "10.0.0.0/16"
}

variable "cidr_blocks" {
	type = "list"
	description = "CIDR blocks for Subnets"
	default = ["10.0.0.0/24", "10.0.1.0/24"]
}
