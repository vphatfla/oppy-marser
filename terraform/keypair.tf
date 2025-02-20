resource "aws_key_pair" "main" {
  key_name   = "mac-keypair"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIaSsW1IJ2kQ3Kdpmh9B34o9BDkuqPp19pzWOSSWhS/ pvphat25@gmail.com"
}
