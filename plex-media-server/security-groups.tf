resource "aws_security_group" "plex_admin" {
  name        = "${var.environment}-plex"
  description = "Allow Administration of the plex server."
  vpc_id      = var.vpc_id

  ingress {
    # SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    # Plex
    from_port   = 32400
    to_port     = 32400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
