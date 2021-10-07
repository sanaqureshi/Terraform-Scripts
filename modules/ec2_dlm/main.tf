resource "random_pet" "rs" {
  length = 2
}

resource "aws_iam_role" "ec2_dlm_role" {
  name = "ec2_dlm_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_dlm_policy" {
  name = "ec2_dlm_policy"
  role = aws_iam_role.ec2_dlm_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DeleteSnapshot",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "dlm-snapshots" {
  description        = "DLM lifecycle policy"
  execution_role_arn = aws_iam_role.ec2_dlm_role.arn
  state              = "ENABLED"
  tags = {
      Name = "dlm-snapshots"
    }

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "1 week of daily snapshots"

      create_rule {
        interval      = 1
        interval_unit = "HOURS"
        times         = ["13:15"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        Name = "snap-${random_pet.rs.id}"
      }

      copy_tags = false
    }

    target_tags = {
      Name = var.ebsname
    }
  }
}
