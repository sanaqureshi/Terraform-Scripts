resource "aws_security_group" "mongodb" {
  name        = "mongodb-sg"
  description = "Security group for mongodb"

  tags = {
      Name = "mongodb-sg"
  }

}

resource "aws_security_group_rule" "mongodb_allow_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mongodb.id}"
}

resource "aws_security_group_rule" "mongodb_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mongodb.id}"
}

resource "aws_security_group_rule" "mongodb_mongodb" {
  type            = "ingress"
  from_port       = 27017
  to_port         = 27017
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mongodb.id}"
}

resource "aws_instance" "mongodb-server" {
    availability_zone = var.az
    user_data = <<-EOF1
                #!/bin/bash
                sudo yum update -y
                echo "[mongodb-org-5.0]
                name=MongoDB Repository
                baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/
                gpgcheck=1
                enabled=1
                gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" >> /etc/yum.repos.d/mongodb-org-4.4.repo
                sudo yum install -y mongodb-org-5.0.2 mongodb-org-database-5.0.2 mongodb-org-server-5.0.2 mongodb-org-shell-5.0.2 mongodb-org-mongos-5.0.2 mongodb-org-tools-5.0.2
                sudo systemctl restart mongod
                sudo sed -i 's/\(bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf
                sudo systemctl restart mongod
                mongo <<-EOF2
                use Forms
                db.formsAPI.insert({ID:100})
                  EOF2
                EOF1
    tags = {
        Name = "mongodb-server"
    }

    ami = var.ami
    instance_type = "t2.micro"

    root_block_device {
        volume_type = "gp2"
        volume_size = "8"
        encrypted = true
        tags = {
            Name = "mongodb-server"
        }
    }

    security_groups = [
        "${aws_security_group.mongodb.name}"
    ]

    associate_public_ip_address = true

    key_name = "masohio"
}
