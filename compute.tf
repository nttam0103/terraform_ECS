
resource "aws_key_pair" "trongtam-keypair" {
  key_name   = "trongtam-keypair"
  public_key = file("../keypair/trongtam.pub")
}

resource "aws_instance" "nat_instance" {
  ami                         = var.amis
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_us-east-2a.id
  associate_public_ip_address = true
  source_dest_check           = false
  security_groups             = [aws_security_group.sg_nat_instance.id]
  key_name                    = aws_key_pair.trongtam-keypair.key_name
  user_data                   = <<-EOF
              #!/bin/bash
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf  

              sysctl -p
              yum install iptables-services -y
              systemctl start iptables
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              iptables -F FORWARD
              service iptables save
              EOF
  tags = {
    Name = "nat__instance"
  }
}

output "nat_instance_public_ip" {
  value = aws_instance.nat_instance.public_ip
}