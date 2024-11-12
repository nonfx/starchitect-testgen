provider "aws" {
  alias  = "pass_aws"
  region = "us-west-2"
}

# Create a compliant launch configuration with public IP disabled
resource "aws_launch_configuration" "pass_config" {
  provider = aws.pass_aws
  name_prefix = "pass-launch-config"
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # Compliant: Explicitly disabling public IP
  associate_public_ip_address = false
  
  security_groups = ["sg-12345678"]
  
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    encrypted   = true
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create autoscaling group using the compliant launch configuration
resource "aws_autoscaling_group" "pass_asg" {
  provider = aws.pass_aws
  name = "pass-asg"
  max_size = 3
  min_size = 1
  desired_capacity = 1
  launch_configuration = aws_launch_configuration.pass_config.name
  vpc_zone_identifier = ["subnet-12345678"]
  
  tag {
    key = "Environment"
    value = "Production"
    propagate_at_launch = true
  }
}
