#!/bin/bash

%{ if install_nginx }
cat <<EOF >/var/lib/rancher/k3s/server/manifests/nginx.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: ingress-nginx
  namespace: kube-system
spec:
  helmVersion: v3
  chart: https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-${nginx_version}/ingress-nginx-${nginx_version}.tgz
  targetNamespace: ingress-nginx
  valuesContent: |-
    controller:
      dnsPolicy: ClusterFirstWithHostNet
      kind: DaemonSet
      watchIngressWithoutClass: true
      hostPort:
        enabled: true
      ingressClassResource:
        default: true
EOF
%{ endif }

%{ if install_certmanager }
kubectl create namespace cert-manager
sleep 5
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v${certmanager_version}/cert-manager.yaml

until [ "$(kubectl get pods --namespace cert-manager | grep Running | wc -l)" = "3" ]; do
  sleep 2
done

%{ if install_rancher }
cat <<EOF >/var/lib/rancher/k3s/server/manifests/rancher.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: rancher
  namespace: kube-system
spec:
  helmVersion: v3
  chart: https://releases.rancher.com/server-charts/latest/rancher-${rancher_version}.tgz
  targetNamespace: cattle-system
  valuesContent: |-
    hostname: ${rancher_hostname}
    ingress:
      tls:
        source: letsEncrypt
    letsEncrypt:
      email: ${letsencrypt_email}
      environment: ${letsencrypt_environment}
    bootstrapPassword: ${rancher_password}
    %{ if features != "" }
    features: "${features}"
    %{ endif }
EOF
%{ endif }
%{ endif }
