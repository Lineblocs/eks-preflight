#!/bin/bash

# preflight_checks will check if requirements for this check are met.
preflight_checks() {
  kubectl version
}

# check_kube_proxy_presence checks if kube-proxy resources are found in ns kube-system.
# It searches for a daemonset named kube-proxy.
# Returns with 0 if present, 1 if not.
check_kube_proxy_presence() {
  kubectl get ds -o=jsonpath='{.items[*].metadata.name}' -n kube-system | grep -w 'kube-proxy' > /dev/null
  if [[ $? == 0 ]]; then
      echo "kube-proxy is present in the cluster !"
      exit 0
  else
      echo "kube-proxy is not present in the cluster"
      exit 1
  fi
}


check_kube_proxy_presence