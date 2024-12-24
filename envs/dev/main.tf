provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "../../modules/network"
  vpc_cidr = "10.0.0.0/16"
  subnet_cidrs = [
    {
        cidr_block = "10.0.1.0/24",
        availability_zone = "us-east-1a"
    },
    {
        cidr_block = "10.0.3.0/24",
        availability_zone = "us-east-1b"
    }
  ]
}

module "alb_security_group" {
  source = "../../modules/security"
  sg_name = "alb_security_group"
  name_prefix = "dev"
  vpc_id = module.network.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ]
}

module "asg_security_group" {
  source = "../../modules/security"
  sg_name = "asg_security_group"
  name_prefix = "dev"
  vpc_id = module.network.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      security_groups = [module.alb_security_group.sg_id]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      security_groups = [module.alb_security_group.sg_id]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ]
}

module "alb" {
  source = "../../modules/load_balancer"
  lb_name = "dev-alb"
  is_lb_internal = false
  lb_security_groups = [module.alb_security_group.sg_id]
  lb_subnets = module.network.subnet_ids
  lb_tg_name = "dev-alb-tg"
    lb_tg_port = 80
    lb_tg_protocol = "HTTP"
    lb_tg_vpc_id = module.network.vpc_id
    lb_tg_target_type = "instance"
    lb_listener_port = 80
    lb_listener_protocol = "HTTP"
    lb_listener_default_action_type = "forward"
}

module "auto_scalling_group" {
    source = "../../modules/auto_scalling_group"
    lt_name_prefix = "dev"
    lt_name = "dev-lt"
    lt_image_id = "ami-01816d07b1128cd2d"
    lt_instance_type = "t3.micro"
    lt_key_name = "asg-lab"
    lt_user_data =  filebase64("../../files/nginx-setup.sh")
    lt_public_ip_enabled = false
    lt_security_groups = [module.asg_security_group.sg_id]
    lt_tags = {
        Name = "dev-lt"
    }
    asg_prefix_name = "dev"
    asg_name = "asg"
    asg_min_size = 1
    asg_max_size = 3
    asg_desired_capacity = 2
    asg_subnets = module.network.subnet_ids
    asg_target_group_arn = [module.alb.lb_tg_arn]
    asg_tags = [
        {
        key = "Name"
        value = "dev-asg"
        propagate_at_launch = true
        },
        {
        key = "Environment"
        value = "dev"
        propagate_at_launch = true
        }
    ]
    asg_policies = [
        {
        name = "dev-asg-policy-scale-up"
        scaling_adjustment = 1
        adjustment_type = "ChangeInCapacity"
        cooldown = 300
        },
        {
        name = "dev-asg-policy-scale-down"
        scaling_adjustment = -1
        adjustment_type = "ChangeInCapacity"
        cooldown = 300
        }
    ]
}



module "cloudwatch_scale_up_alarm" {
  source = "../../modules/cloudwatch"
  cloudwatch_alarm_name = "dev-alarm"
  cloudwatch_alarm_description = "This metric monitors the CPU utilization of the EC2 instances"
  // get policy arn from the module where the policy name is defined as dev-asg-policy
  cloudwatch_alarm_actions = [module.auto_scalling_group.asg_policy_arn[0]]
  cloudwatch_alarm_metric_name = "CPUUtilization"
  cloudwatch_alarm_namespace = "AWS/EC2"
  cloudwatch_alarm_statistic = "Average"
  cloudwatch_alarm_period = "300"
  cloudwatch_alarm_evaluation_periods = "1"
  cloudwatch_alarm_threshold = "80"
  cloudwatch_alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
  cloudwatch_alarm_dimensions = {
    AutoScalingGroupName = module.auto_scalling_group.asg_name
  }
}