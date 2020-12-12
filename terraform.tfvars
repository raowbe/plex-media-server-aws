environment       = "env-name"
ssh_key_name      = "ssh-key-name"
vpc_id            = "vpc-xxxxxxxx"
subnet_id         = "subnet-xxxxxxxx"
availability_zone = "us-east-1c"
my_ip             = "x.x.x.x"
plex_libraries    = ["library1", "library2"]
sns_email_address = "youremail@example.com"

# instance_types    = ["t3.micro", "t2.micro"]
# architecture      = "x86_64"
# spot              = true

instance_types    = ["t4g.micro"]
architecture      = "arm64"
spot              = false