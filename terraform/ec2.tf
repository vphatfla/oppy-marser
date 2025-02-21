resource "aws_instance" "app" {
  ami           = "ami-053a45fff0a704a47"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id
  key_name  = aws_key_pair.main.key_name

  vpc_security_group_ids = [aws_security_group.ec2_public.id]

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.app_name}-ec2"
  }
}
