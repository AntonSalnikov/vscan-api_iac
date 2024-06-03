
resource "aws_security_group" "alb_sg" {

  name        = "application_lb_sg"
  description = "Allow traffic for vscan-api Backend public ports"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, {Name: "application_lb_sg"})
}

resource "aws_security_group_rule" "alb_sg_ingress_rule_from_48081" {
  from_port = 48081
  protocol = "TCP"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 48081
  type = "ingress"
  description = "Provides access on 80 port"
}

resource "aws_security_group_rule" "alb_sg_ingress_rule_from_443" {
  from_port = 443
  protocol = "TCP"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 443
  type = "ingress"
  description = "Provides access on ssl port"
}

resource "aws_security_group_rule" "alb_sg_egress_rule" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.alb_sg.id
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

data "aws_elb_service_account" "main" {}

resource "aws_lb" "vscan-network-alb" {
  name               = "vscan-tcp-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = true

  idle_timeout = 60

  tags = local.tags
}

resource "aws_lb_target_group" "vsacn_api_backend_tg" {
  name     = local.application_name
  port     = local.container_http_port
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  tags = local.tags
  deregistration_delay = 120
  target_type = "ip"

  health_check {
    path = "/health"
    interval = 5
    timeout = 3
  }

  depends_on = [aws_lb.vscan-network-alb]
}


resource "aws_lb_target_group" "vsacn_tcp_backend_tg" {
  name     = "${local.application_name}-tcp"
  port     = local.container_tcp_port
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  tags = local.tags
  deregistration_delay = 120
  target_type = "ip"

  health_check {
    port = "8080"
    path = "/health"
    interval = 5
    timeout = 3
  }

  depends_on = [aws_lb.vscan-network-alb]
}

data "aws_acm_certificate" "public_domain_name_cert" {
  domain = local.public_domain_name
}

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.vscan-network-alb.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.public_domain_name_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.vsacn_api_backend_tg.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "tcp-listener" {
  load_balancer_arn = aws_lb.vscan-network-alb.arn
  port              = "48081"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.vsacn_tcp_backend_tg.id
    type             = "forward"
  }
}
