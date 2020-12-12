data "aws_iam_policy_document" "plex_ec2" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = flatten([
      for bucket in var.s3_buckets : [
        bucket.arn,
        "${bucket.arn}/*"
      ]
    ])
  }

  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume"
    ]
    resources = [
      var.ebs_volume.arn,
      "arn:aws:ec2:*:*:instance/*"
    ]
  }

  statement {
    actions = [
      "ssm:DescribeParameters",
      "ec2:AssociateAddress"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      aws_ssm_parameter.plex_claim_token.arn
    ]
  }

}

resource "aws_iam_policy" "plex_server" {
  name        = "${var.environment}-plex-ec2"
  description = "Policy for ec2 role to get access to s3, ssm, kms, ebs."
  policy = data.aws_iam_policy_document.plex_ec2.json
}


resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-plex-ec2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "plex_server_policy_to_ec2_role" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.plex_server.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-plex"
  role = aws_iam_role.ec2_role.name
}
