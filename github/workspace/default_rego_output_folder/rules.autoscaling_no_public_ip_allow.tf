# Configure AWS provider for passing test case
provider "aws" {
  alias  = "pass_aws"
  region = "us-west-2"
}

# Create a compliant launch configuration that doesn't assign public IPs
resource "aws_launch_configuration" "pass_config" {
  provider = aws.pass_aws
  name_prefix   = "pass-launch-config"
  image_id      = "ami-12345678"
  instance_type = "t2.micro"

  # Compliant: Explicitly disables public IP address assignment
  associate_public_ip_address = false

  security_groups = ["sg-12345678"]

  lifecycle {
    create_before_destroy = true
  }
}

# Create an auto scaling group using the compliant launch configuration
resource "aws_autoscaling_group" "pass_asg" {
  provider = aws.pass_aws
  name                = "pass-asg"
  launch_configuration = aws_launch_configuration.pass_config.name
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = ["subnet-12345678"]
}
