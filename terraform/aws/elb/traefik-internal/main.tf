variable short_name { }
variable instances {}
variable subnets {}
variable security_groups {}

resource "aws_elb" "traefik-internal-elb" {
  name = "${var.short_name}-traefik-internal-elb"
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  subnets = ["${split(\",\", var.subnets)}"]
  security_groups = ["${split(\",\", var.security_groups)}"]
  instances = ["${split(\",\", var.instances)}"]
  internal = true

  listener {
    instance_port = 82
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:82"
    interval = 30
  }

  tags {
    Name = "${var.short_name}-elb"
  }
}

output "fqdn" {
  value = "${aws_elb.traefik-internal-elb.dns_name}"
}

output "zone_id" {
  value = "${aws_elb.traefik-internal-elb.zone_id}"
}
