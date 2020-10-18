resource "aws_ssm_parameter" "CW-Windows-Config" {
  name  = "CW-Windows-Config"
  type  = "String"
  value = <<EOF
{
    "metrics": {
        "append_dimensions": {
            "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
            "InstanceId": "$${aws:InstanceId}"
        },
        "metrics_collected": {
            "LogicalDisk": {
                "measurement": [
                    "% Free Space"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "Memory": {
                "measurement": [
                    "% Committed Bytes In Use"
                ],
                "metrics_collection_interval": 60
            },
            "statsd": {
                "metrics_aggregation_interval": 60,
                "metrics_collection_interval": 60,
                "service_address": ":8125"
            }
        }
    }
}
EOF
}

resource "aws_ssm_parameter" "CW-Linux-Config" {
  name  = "CW-Linux-Config"
  type  = "String"
  value = <<EOF
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "cwagent"
	},
	"metrics": {
		"append_dimensions": {
			"AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
			"InstanceId": "$${aws:InstanceId}"
		},
		"metrics_collected": {
			"disk": {
				"measurement": [
					"used_percent"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				],
                "ignore_file_system_types": [
                    "devtmpfs",
                    "overlay",
                    "squashfs",
                    "tmpfs",
                    "nfs4"
                   ]
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			},
			"statsd": {
				"metrics_aggregation_interval": 60,
				"metrics_collection_interval": 10,
				"service_address": ":8125"
			}
		}
	}
}
  EOF
}

