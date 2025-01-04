resource "aws_vpc" "my_name" {
  cidr_block = "0.0.0.0/0"
  availability_zone = "us-east-2"
}