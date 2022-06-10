terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 1.23"
    }
    aws = {
      source = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
    }
  }
}


provider "aws" {}

provider "aws" {
  alias = "r53"
}

locals {
  name                           = var.name
  install_k3s_version            = var.install_k3s_version
  k3s_cluster_secret             = var.k3s_cluster_secret != null ? var.k3s_cluster_secret : random_password.k3s_cluster_secret.result
  server_instance_type           = var.server_instance_type
  server_volume_type             = var.server_volume_type
  agent_instance_type            = var.agent_instance_type
  agent_volume_type              = var.agent_volume_type
  agent_image_id                 = var.agent_image_id != null ? var.agent_image_id : data.aws_ami.ubuntu.id
  server_image_id                = var.server_image_id != null ? var.server_image_id : data.aws_ami.ubuntu.id
  aws_azs                        = var.aws_azs
  public_subnets                 = length(var.public_subnets) > 0 ? var.public_subnets : data.aws_subnets.available.ids
  private_subnets                = length(var.private_subnets) > 0 ? var.private_subnets : data.aws_subnets.available.ids
  server_node_count              = var.server_node_count
  agent_node_count               = var.agent_node_count
  ssh_keys                       = var.ssh_keys
  deploy_rds                     = var.k3s_datastore_endpoint != "sqlite" ? 1 : 0
  db_instance_type               = var.db_instance_type
  db_user                        = var.db_user
  db_pass                        = var.db_pass
  db_name                        = var.db_name != null ? var.db_name : var.name
  db_engine_version              = var.db_engine_version
  db_allow_major_version_upgrade = var.db_allow_major_version_upgrade
  db_parameter_group_family      = var.db_parameter_group_family
  db_node_count                  = var.k3s_datastore_endpoint != "sqlite" ? var.db_node_count : 0
  k3s_datastore_cafile           = var.k3s_datastore_cafile
  k3s_datastore_endpoint         = var.k3s_datastore_endpoint == "sqlite" ? null : "postgres://${local.db_user}:${local.db_pass}@${aws_rds_cluster.k3s.0.endpoint}/${local.db_name}"
  k3s_disable_agent              = var.k3s_disable_agent ? "--disable-agent" : ""
  k3s_tls_san                    = var.k3s_tls_san != null ? var.k3s_tls_san : "--tls-san ${aws_lb.server-lb.dns_name}"
  server_k3s_exec                = var.server_k3s_exec != null ? var.server_k3s_exec : ""
  agent_k3s_exec                 = var.agent_k3s_exec != null ? var.agent_k3s_exec : ""
  certmanager_version            = var.certmanager_version
  rancher_version                = var.rancher_version
  letsencrypt_email              = var.letsencrypt_email
  letsencrypt_environment        = var.letsencrypt_environment
  domain                         = var.domain
  r53_domain                     = length(var.r53_domain) > 0 ? var.r53_domain : local.domain
  private_subnets_cidr_blocks    = var.private_subnets_cidr_blocks
  public_subnets_cidr_blocks     = var.public_subnets_cidr_blocks
  skip_final_snapshot            = var.skip_final_snapshot
  install_certmanager            = var.install_certmanager
  install_nginx                  = var.install_nginx
  nginx_version                  = var.nginx_version
  install_rancher                = var.install_rancher
  create_external_nlb            = var.create_external_nlb ? 1 : 0
  registration_command           = var.registration_command
  rancher_password               = var.rancher_password
  rancher_features               = var.rancher_features
  rancher_token_update           = var.rancher_token_update
  use_route53                    = var.use_route53 ? local.create_external_nlb : 0
  subdomain                      = var.subdomain != null ? var.subdomain : var.name
  rds_ca_cert_identifier         = var.rds_ca_cert_identifier
}

resource "random_password" "k3s_cluster_secret" {
  length  = 30
  special = false
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${local.subdomain}.${local.domain}"
  bootstrap = true
}

resource "null_resource" "wait_for_rancher" {
  count = local.install_rancher ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
until echo "$${subject}" | grep "CN=${local.subdomain}.${local.domain}"; do
    sleep 5
    subject=$(curl -vk -m 2 "https://${local.subdomain}.${local.domain}/ping" 2>&1 | grep "subject:")
done
while [ "$${resp}" != "pong" ]; do
    resp=$(curl -sSk -m 2 "https://${local.subdomain}.${local.domain}/ping")
    echo "Rancher Response: $${resp}"
    if [ "$${resp}" != "pong" ]; then
      sleep 10
    fi
done
EOF


    environment = {
      RANCHER_HOSTNAME = "${local.subdomain}.${local.domain}"
    }
  }
  depends_on = [
    aws_autoscaling_group.k3s_server,
    aws_autoscaling_group.k3s_agent,
    aws_rds_cluster_instance.k3s
  ]
}

resource "rancher2_bootstrap" "admin" {
  count            = local.install_rancher ? 1 : 0
  provider         = rancher2.bootstrap
  initial_password = local.rancher_password
  token_update     = local.rancher_token_update
  depends_on       = [null_resource.wait_for_rancher]
}
