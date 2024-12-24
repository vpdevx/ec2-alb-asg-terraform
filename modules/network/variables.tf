variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable subnet_cidrs {
    description = "The CIDR blocks for the subnets"
    type        = list(object({
        cidr_block = string
        availability_zone = string
    }))
    default = [
        {
            cidr_block = "10.0.1.0/24",
            availability_zone = "us-east-1a"
        },
        {
            cidr_block = "10.0.2.0/24",
            availability_zone = "us-east-1b"
        }
    ]
}