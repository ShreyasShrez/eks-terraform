resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-main"
  }
}

resource "aws_security_group" "sg" {
 name        = "vpce"
 description = "Allow HTTPS to web server"
 vpc_id      = aws_vpc.main.id

ingress {
   description = "HTTPS ingress"
   from_port   = 443
   to_port     = 443
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

# resource "aws_vpc_endpoint" "ec2" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.ap-south-1.ec2"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

#   security_group_ids = [
#     aws_security_group.sg.id,
#   ]

#   private_dns_enabled = true
# }
