resource "aws_vpc" "tf_tf_myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "tf_subnet1" {
  vpc_id                  = aws_vpc.tf_myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tf_subnet2" {
  vpc_id                  = aws_vpc.tf_myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "tf_internet_gateway" {
  vpc_id = aws_vpc.tf_myvpc.id
}

resource "aws_route_table" "tf_route_table" {
  vpc_id = aws_vpc.tf_myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_internet_gateway.id
  }
}

resource "aws_route_tabla_association" "tf_route_table_association1" {
  subnet_id      = aws_subnet.tf_subnet1.id
  route_table_id = aws_route_table.tf_route_table.id
}

resource "aws_route_tabla_association" "tf_route_table_association2" {
  subnet_id      = aws_subnet.tf_subnet2.id
  route_table_id = aws_route_table.tf_route_table.id
}

