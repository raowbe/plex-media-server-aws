module "plex_storage" {
    source            = "./plex-storage"
    environment       = var.environment
    availability_zone = var.availability_zone
    plex_libraries    = var.plex_libraries
}

module "plex_media_server" {
    source            = "./plex-media-server"
    environment       = var.environment
    ssh_key_name      = var.ssh_key_name
    vpc_id            = var.vpc_id
    subnet_id         = var.subnet_id
    availability_zone = var.availability_zone
    my_ip             = var.my_ip
    plex_claim_token  = var.plex_claim_token
    s3_buckets        = module.plex_storage.s3_buckets
    ebs_volume        = module.plex_storage.ebs_volume
    instance_types    = var.instance_types
    sns_email_address = var.sns_email_address
    architecture      = var.architecture
    spot              = var.spot
}
