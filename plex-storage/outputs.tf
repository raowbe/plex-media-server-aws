output "s3_buckets" {
  value = aws_s3_bucket.plex
}

output "ebs_volume" {
  value = aws_ebs_volume.plex_data
}
