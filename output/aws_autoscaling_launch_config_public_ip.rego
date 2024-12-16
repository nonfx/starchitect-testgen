package rules.autoscaling_launch_config_public_ip

import data.fugue

__rego__metadoc__ := {
    "id": "Autoscaling.5",
    "title": "Amazon EC2 instances launched using Auto Scaling group launch configurations should not have Public IP addresses",
    "description": "Auto Scaling group launch configurations must not assign public IP addresses to EC2 instances for enhanced security. Instances should only be accessible through load balancers and not directly exposed to the internet.",
    "custom": {
        "controls": {"AWS-Foundational-Security-Best-Practices_v1.0.0": ["AWS-Foundational-Security-Best-Practices_v1.0.0_Autoscaling.5"]},
        "severity": "High"
    }
}

resource_type := "MULTIPLE"

# Get all launch configurations
launch_configs = fugue.resources("aws_launch_configuration")

# Helper function to check if public IP is disabled
is_public_ip_disabled(config) {
    config.associate_public_ip_address == false
}

is_public_ip_disabled(config) {
    not config.associate_public_ip_address
}

# Allow configurations with public IP disabled
policy[p] {
    config := launch_configs[_]
    is_public_ip_disabled(config)
    p = fugue.allow_resource(config)
}

# Deny configurations with public IP enabled
policy[p] {
    config := launch_configs[_]
    not is_public_ip_disabled(config)
    p = fugue.deny_resource_with_message(
        config,
        "Launch configuration should not assign public IP addresses to EC2 instances"
    )
}
