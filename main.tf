resource "aws_vpc" "tf_myvpc" {
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

resource "aws_route_table_association" "tf_route_table_association1" {
  subnet_id      = aws_subnet.tf_subnet1.id
  route_table_id = aws_route_table.tf_route_table.id
}

resource "aws_route_table_association" "tf_route_table_association2" {
  subnet_id      = aws_subnet.tf_subnet2.id
  route_table_id = aws_route_table.tf_route_table.id
}

resource "aws_security_group" "tf-security-group" {
  name        = "web-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.tf_myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "security_group"
  }
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "tf-bucket-vpc-project-daniel-zerihon"
}

resource "aws_instance" "tf_ec2_subnet1" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf-security-group.id]
  subnet_id              = aws_subnet.tf_subnet1.id
  user_data              = base64encode(file("userdata_subnet1.sh"))
}

resource "aws_instance" "tf_ec2_subnet2" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf-security-group.id]
  subnet_id              = aws_subnet.tf_subnet2.id
  user_data              = base64encode(file("userdata_subnet2.sh"))
}

#create alb 
resource "aws_lb" "myalb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf-security-group.id]
  subnets            = [aws_subnet.tf_subnet1.id, aws_subnet.tf_subnet2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tf_my_alb_target_group" {
  name     = "targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tf_alb_target_group_attachment_1" {
  target_group_arn = aws_lb_target_group.tf_my_alb_target_group.arn
  target_id        = aws_instance.tf_ec2_subnet1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tf_alb_target_group_attachment_2" {
  target_group_arn = aws_lb_target_group.tf_my_alb_target_group.arn
  target_id        = aws_instance.tf_ec2_subnet2.id
  port             = 80
}

resource "aws_lb_listener" "tf_listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tf_my_alb_target_group.arn
    type             = "forward"
  }
}

output "loadbancerdns" {
  value = aws_lb.myalb.dns_name
}