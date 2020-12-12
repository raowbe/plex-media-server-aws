resource "aws_ssm_parameter" "plex_claim_token" {
  name        = "/${var.environment}/plex/claim_token"
  description = "Claim token for plex."
  type        = "SecureString"
  value       = var.plex_claim_token
}
