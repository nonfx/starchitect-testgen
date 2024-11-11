# Configure AWS provider for failing test case
provider "aws" {
  alias  = "fail_aws"
  region = "us-west-2"
}

# Create a non-compliant launch configuration that assigns public IPs
resource "aws_launch_configuration" "fail_config" {
  provider = aws.fail_aws
  name_prefix   = "fail-launch-config"
  image_id      = "ami-12345678"
  instance_type = "t2.micro"

  # Non-compliant: Explicitly assigns public IP addresses
  associate_public_ip_address = true

  security_groups = ["sg-12345678"]

  lifecycle {
    create_before_destroy = true
  }
}

# Create an auto scaling group using the non-compliant launch configuration
resource "aws_autoscaling_group" "fail_asg" {
  provider = aws.fail_aws
  name                = "fail-asg"
  launch_configuration = aws_launch_configuration.fail_config.name
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = ["subnet-12345678"]
}
