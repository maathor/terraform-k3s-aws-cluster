#!/bin/bash

%{ if is_k3s_server }
%{ if k3s_datastore_endpoint != "sqlite" }
curl -o ${k3s_datastore_cafile} https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
%{ endif }
%{ endif }

until (curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v${install_k3s_version}' INSTALL_K3S_EXEC='%{ if is_k3s_server }${k3s_tls_san} ${k3s_disable_agent} %{ endif}${k3s_exec}' K3S_TOKEN='${k3s_cluster_secret}' %{ if is_k3s_server }%{ if k3s_datastore_endpoint != "sqlite" }K3S_DATASTORE_CAFILE='${k3s_datastore_cafile}'%{ endif } %{ if k3s_datastore_endpoint != "sqlite" }K3S_DATASTORE_ENDPOINT='${k3s_datastore_endpoint}'%{ endif } %{ endif }%{ if !is_k3s_server } K3S_URL='https://${k3s_url}:6443'%{ endif } sh -); do
  echo 'k3s did not install correctly'
  sleep 2
done

%{ if is_k3s_server }
until kubectl get pods -A | grep 'Running'; do
  echo 'Waiting for k3s startup'
  sleep 5
done
%{ endif }

# K10ac66c93782b9aa3348de3e505968a339fbca35af2086a473e038545e98c6ddf9::server:Tickled25Breaded10siberia

# server
#curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.21.4+k3s1' INSTALL_K3S_EXEC='--tls-san rancher-mgmt-int-regular-e219418f57fe582a.elb.us-east-1.amazonaws.com --no-deploy local-storage' K3S_TOKEN='Tickled25Breaded10siberia' K3S_DATASTORE_CAFILE='/srv/rds-combined-ca-bundle.pem' K3S_DATASTORE_ENDPOINT='postgres://k3s:claimed30Whitman@rancher-mgmt-20211028044607251000000003.cluster-cijvgx1emidk.us-east-1.rds.amazonaws.com/k3s'  sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.22.9+k3s1' INSTALL_K3S_EXEC='--tls-san rancher-mgmt-int-regular-e219418f57fe582a.elb.us-east-1.amazonaws.com --no-deploy local-storage' K3S_TOKEN='Tickled25Breaded10siberia' K3S_DATASTORE_CAFILE='/srv/rds-combined-ca-bundle.pem' K3S_DATASTORE_ENDPOINT='postgres://k3s:claimed30Whitman@rancher-mgmt-20211028044607251000000003.cluster-cijvgx1emidk.us-east-1.rds.amazonaws.com/k3s'  sh -

# agent
#curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.21.4+k3s1' INSTALL_K3S_EXEC='' K3S_TOKEN='Tickled25Breaded10siberia'  K3S_URL='https://rancher-mgmt-int-regular-e219418f57fe582a.elb.us-east-1.amazonaws.com:6443' sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.22.9+k3s1' INSTALL_K3S_EXEC='' K3S_TOKEN='Tickled25Breaded10siberia'  K3S_URL='https://rancher-mgmt-int-regular-e219418f57fe582a.elb.us-east-1.amazonaws.com:6443' sh -