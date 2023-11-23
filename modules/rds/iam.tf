resource "aws_iam_role" "rds_monitoring_role"{
    name = "rds-monitoring-role-${var.environment}"

    assume_role_policy = jsonencode(
    {
        Version = "2012-10-17",
        Statement = [ 
            {
                Sid = "",
                Effect = "Allow",
                Principal = {
                    Service = "monitoring.rds.amazonaws.com"
                    },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

data "aws_iam_policy" "rds_monitoring_policy"{
    name = "AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_role_attachment"{
    role = aws_iam_role.rds_monitoring_role.name
    policy_arn = data.aws_iam_policy.rds_monitoring_policy.arn
}
