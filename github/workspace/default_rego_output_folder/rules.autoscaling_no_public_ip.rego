package rules.autoscaling_no_public_ip

import data.fugue

__rego__metadoc__ := {
    "id": "Autoscaling.5",
    "title": "Auto Scaling launch configurations should not assign public IP addresses",
    "description": "Amazon EC2 instances launched using Auto Scaling group launch configurations should not have Public IP addresses to enhance network security and prevent direct internet exposure.",
    "custom": {
        "controls": {"AWS-Foundational-Security-Best-Practices_v1.0.0": ["AWS-Foundational-Security-Best-Practices_v1.0.0_Autoscaling.5"]},
        "severity": "High"
    }
}

resource_type := "MULTIPLE"

# Get all launch configuration resources
launch_configs = fugue.resources("aws_launch_configuration")

# Function to check if public IP assignment is disabled
is_public_ip_disabled(config) {
    not config.associate_public_ip_address
}

is_public_ip_disabled(config) {
    config.associate_public_ip_address == false
}

# Allow resources that don't assign public IPs
policy[p] {
    config := launch_configs[_]
    is_public_ip_disabled(config)
    p = fugue.allow_resource(config)
}

# Deny resources that assign public IPs
policy[p] {
    config := launch_configs[_]
    not is_public_ip_disabled(config)
    p = fugue.deny_resource_with_message(config, "Auto Scaling launch configuration should not assign public IP addresses to EC2 instances")
}
