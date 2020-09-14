variable "region" {
    default = ""
}

variable "envr" {
    default = ""
}

variable "lbtype" {
    default = ""
}

variable "appname" {
    default = ""
}

variable "internal" {
    default = ""
}

variable "subnet" {
    default = ""
}

variable "lb_type" {
    default = ""
}

variable "enable_deletion_protection" {
    default = ""
}

variable "idle_timeout" {
    default = ""
}

variable "application" {
    default = ""
}


variable "port" {
  default = ""
}

variable "protocol" {
  default = ""
}

variable "vpc_id" {
    default = ""
}



variable "elbinstance1" {
 default = ""
}

variable "elbinstance2" {
 default = ""
}


resource "aws_lb" "lb" {
  name               = "${var.region}-${var.envr}-${var.lbtype}-${var.appname}"
  internal           = "${var.internal}"
  #security_groups    = ["${var.security_group_ids}"]
  subnets            = ["${var.subnet}"]
  load_balancer_type = "${var.lb_type}"

  enable_deletion_protection = "${var.enable_deletion_protection}"
  idle_timeout               = "${var.idle_timeout}"

tags {
    Name               = "${var.region}-${var.envr}-${var.lbtype}-${var.appname}"
    Application        = "${var.application}"
  }

}

resource "aws_lb_target_group" "tg" {

  name     = "${var.region}-${var.envr}-TG-${var.appname}"
  port     = "${var.port}"
  protocol = "${var.protocol}"
  vpc_id   = "${var.vpc_id}"
  stickiness = []

 tags {
    Name               = "${var.region}-${var.envr}-TG-${var.appname}"
    Application        = "${var.application}"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.port}"
  protocol          = "${var.protocol}"
  #ssl_policy        = "ELBSecurityPolicy-2015-05"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg.arn}"
  }
}


resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = "${aws_lb_target_group.tg.arn}"
  target_id        = "${var.elbinstance1}"
  port             = "${var.port}"
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = "${aws_lb_target_group.tg.arn}"
  target_id        = "${var.elbinstance2}"
  port             = "${var.port}"
}


