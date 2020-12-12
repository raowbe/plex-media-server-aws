variable environment {
    description = "Name of your plex environment."
}

variable ssh_key_name {
    description = "Name of ssh key to ssh to ec2 instance."
}

variable vpc_id {}
variable subnet_id {}
variable availability_zone {}

variable my_ip {
    description = "My IP Address.  Used for security groups to allow traffic from only me."
}

variable plex_claim_token {
    type = string
}

variable s3_buckets {
    type = list
}

variable ebs_volume {
    # type = map
}

variable instance_types {
    type = list
}

variable sns_email_address {
    type = string
}

variable architecture {
    type = string
    default = "x86_64"
}

variable spot {
    type = bool
    default = true
}