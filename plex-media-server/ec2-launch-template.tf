locals {
  buckets = flatten([
    for bucket in var.s3_buckets : [
      bucket.id
    ]
  ])

  bucket_fstab_list = flatten([
    for bucket in var.s3_buckets : [
      "plex\\x2ddata-${replace(bucket.id, "-", "\\x2d")}.mount"
    ]
  ])

  bucket_fstab_string = join(" ", local.bucket_fstab_list)
}

data "aws_ami" "plex" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "name"
    values = ["plex-*"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture] # x86_64 or arm64
  }
}

resource "aws_launch_template" "plex" {
  name = "${var.environment}-plex"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type = "gp3"
      volume_size = 8
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  image_id = data.aws_ami.plex.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.instance_types[0]

  key_name = var.ssh_key_name

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.plex_admin.id]
    subnet_id = var.subnet_id
  }

  placement {
    availability_zone = var.availability_zone
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh", 
      { 
        VOLUME_ID = var.ebs_volume.id, 
        ENVIRONMENT = var.environment, 
        IAM_ROLE = aws_iam_role.ec2_role.name, 
        BUCKETS = local.buckets, 
        BUCKET_FSTAB_STRING = local.bucket_fstab_string 
        EIP_ID = aws_eip.plex.id
      }
    ))
}
