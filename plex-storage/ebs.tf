resource "aws_ebs_volume" "plex_data" {
  availability_zone = var.availability_zone
  size              = 1
  type              = "gp3"
}
