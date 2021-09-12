resource "aws_key_pair" "this" {
  count = var.create_key_pair ? 1 : 0

  key_name   = var.provisioning_key
  public_key = var.public_key
}

resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.provisioning_key
  subnet_id              = var.subnet
  vpc_security_group_ids = var.security_groups
  user_data              = var.user_data

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = merge(
    {
      "Name" = format(
        "%s-instance-%s",
        var.name,
        count.index
      )
    },
    var.tags,
    var.instance_tags
  )
}