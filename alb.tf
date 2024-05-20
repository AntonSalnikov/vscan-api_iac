
resource "aws_security_group" "alb_sg" {

  name        = "application_lb_sg"
  description = "Allow traffic for vscan-api Backend public ports"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, {Name: "application_lb_sg"})
}

resource "aws_security_group_rule" "alb_sg_ingress_rule_from_80" {
  from_port = 80
  protocol = "TCP"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 80
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

resource "aws_alb" "vscan-api-alb" {
  name               = "vscan-api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = true

  idle_timeout = 60

  tags = local.tags
}

resource "aws_alb_target_group" "vsacn_api_backend_tg" {
  name     = local.application_name
  port     = local.container_http_port
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  tags = local.tags
  deregistration_delay = 120
  target_type = "ip"

  health_check {
    path = "/health"
    interval = 5
    timeout = 3
  }

  depends_on = [aws_alb.vscan-api-alb]
}


resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_alb.vscan-api-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_acm_certificate" "public_domain_name_cert" {
  domain = local.public_domain_name
}

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_alb.vscan-api-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.public_domain_name_cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No resource found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "api-access" {
  listener_arn = aws_lb_listener.https-listener.arn
  priority     = 100

  action {
    target_group_arn = aws_alb_target_group.vsacn_api_backend_tg.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [aws_route53_record.app.name]
    }
  }
}
