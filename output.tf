output "rancher_admin_password" {
  value     = local.install_rancher ? rancher2_bootstrap.admin.0.password : null
  sensitive = true
}

output "rancher_url" {
  value = local.install_rancher ? rancher2_bootstrap.admin.0.url : null
}

output "rancher_token" {
  value     = local.install_rancher ? rancher2_bootstrap.admin.0.token : null
  sensitive = true
}

output "external_lb_dns_name" {
  value = local.create_external_nlb > 0 ? aws_lb.lb.0.dns_name : null
}

output "k3s_cluster_secret" {
  value     = local.k3s_cluster_secret
  sensitive = true
}

output "agent_role_arn" {
  value = aws_iam_role.agent_role.arn
}

output "server_role_arn" {
  value = aws_iam_role.server_role.arn
}

output "ext_loadbalancer_dns_name" {
  value = local.create_external_nlb ? aws_lb.lb[0].dns_name : ""
}

output "ext_loadbalancer_arn" {
  value = local.create_external_nlb ? aws_lb.lb[0].arn : ""
}

output "ext_loadbalancer_id" {
  value = local.create_external_nlb ? aws_lb.lb[0].id : ""
}

output "ext_loadbalancer_zone_id" {
  value = local.create_external_nlb ? aws_lb.lb[0].zone_id : ""
}
