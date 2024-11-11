provider "aws" {
  alias  = "fail_aws"
  region = "us-west-2"
}

# Create a non-compliant launch configuration with public IP enabled
resource "aws_launch_configuration" "fail_config" {
  provider = aws.fail_aws
  name_prefix = "fail-launch-config"
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # Non-compliant: Explicitly enabling public IP
  associate_public_ip_address = true
  
  security_groups = ["sg-12345678"]
  
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create autoscaling group using the non-compliant launch configuration
resource "aws_autoscaling_group" "fail_asg" {
  provider = aws.fail_aws
  name = "fail-asg"
  max_size = 3
  min_size = 1
  desired_capacity = 1
  launch_configuration = aws_launch_configuration.fail_config.name
  vpc_zone_identifier = ["subnet-12345678"]
}
