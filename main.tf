resource "aws_vpc" "lab_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_subnet" "lab_subnet" {
    vpc_id     = aws_vpc.lab_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}

resource "aws_route_table" "lab_route_table" {
    vpc_id = aws_vpc.lab_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab_igw.id
    }
}

resource "aws_route_table_association" "lab_aws_route_table_association" {
    subnet_id      = aws_subnet.lab_subnet.id
    route_table_id = aws_route_table.lab_route_table.id
  
}



resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "asg_sg" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "lab_lb" {
  name = "lab_lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = [aws_subnet.lab_subnet.id]
}

resource "aws_lb_target_group" "lab_target_group" {
  name = "lab_target_group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.lab_vpc.id
  target_type = "instance"
}

resource "aws_lb_listener" "lab_listener" {
    load_balancer_arn = aws_lb.lab_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.lab_target_group.arn
    }
}

resource "aws_lauch_template" "lab_launch_template" {
  name = "lab_launch_template"
  image_id = "ami-01816d07b1128cd2d"
  instance_type = "t3.micro"
  key_name = var.key_par_name

  user_data = filebase64("${path.module}/files/nginx-setup.sh")

  network_interfaces {
    security_groups = [aws_security_group.asg_sg.id]
    associate_public_ip_address = false
  }

}

resource "aws_autoscaling_group" "lab_asg" {
  name = "lab_asg"
  max_size = 3
  min_size = 1
  desired_capacity = 1
  launch_template {
    id = aws_lauch_template.lab_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.lab_subnet.id]
  target_group_arns = [aws_lb_target_group.lab_target_group.arn]

  tag {
    key = "Name"
    value = "lab_asg"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "lab_asg_policy_scale_up" {
  name = "lab_asg_policy_scale_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 180
  autoscaling_group_name = aws_autoscaling_group.lab_asg.name
}

resource "aws_autoscaling_policy" "lab_asg_policy_scale_down" {
  name = "lab_asg_policy_scale_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 180
  autoscaling_group_name = aws_autoscaling_group.lab_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_usage" {
  alarm_name = "high_cpu_usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 30
  statistic = "Average"
  threshold = 25
  alarm_description = "This metric monitors ec2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.lab_asg_policy_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.lab_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_usage" {
  alarm_name = "high_cpu_usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 30
  statistic = "Average"
  threshold = 24
  alarm_description = "This metric monitors ec2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.lab_asg_policy_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.lab_asg.name
  }
}
