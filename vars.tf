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
    description = "My IP Address.  Used for security groups to allow traffic from only your ip address for ssh access."
}

variable plex_claim_token {
    type = string
    description = "Token to claim your plex media server.  You can get this by going to https://www.plex.tv/claim."
}

variable plex_libraries {
    type = list
    description = "List of libraries that you will have in plex.  An S3 bucket will be created for each of these."
}

variable instance_types {
    type = list
    description = "List of ec2 instance types to use in the mixed instnace policy for the auto-scaling group.  Note: t3.nano servers crash and burn, so use at least t3.micro/t2.micro."
}

variable sns_email_address {
    type = string
    description = "Email address for SNS notifications.  Use for auto-scaling events."
}

variable architecture {
    type = string
    default = "x86_64"
}

variable spot {
    type = bool
    default = true
}