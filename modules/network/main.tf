resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "this" {
    count = length(var.subnet_cidrs)
    vpc_id = aws_vpc.this.id
    cidr_block = var.subnet_cidrs[count.index].cidr_block
    availability_zone = var.subnet_cidrs[count.index].availability_zone
}

resource "aws_route_table" "this" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
}

resource "aws_route_table_association" "this" {
    count = length(aws_subnet.this)
    subnet_id      = aws_subnet.this[count.index].id
    route_table_id = aws_route_table.this.id
}