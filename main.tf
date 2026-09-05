resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ami_info.id
  instance_type          = "t3.small"
  subnet_id              = "subnet-06bb1587d66a74e4a" # replace your Subnet
  vpc_security_group_ids = ["sg-024229c50f3b369a1"]   # replace your SG
  user_data              = file("jenkins.sh")

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami                    = data.aws_ami.ami_info.id
  instance_type          = "t3.small"
  subnet_id              = "subnet-06bb1587d66a74e4a" # replace your Subnet
  vpc_security_group_ids = ["sg-024229c50f3b369a1"]   # replace your SG
  user_data              = file("jenkins-agent.sh")

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "jenkins-agent"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = var.zone_id

  records = [
    {
      name            = "jenkins"
      type            = "A"
      ttl             = 1
      records         = [aws_instance.jenkins.public_ip]
      allow_overwrite = true
    },
    {
      name            = "jenkins-agent"
      type            = "A"
      ttl             = 1
      records         = [aws_instance.jenkins_agent.private_ip]
      allow_overwrite = true
    }
  ]
}