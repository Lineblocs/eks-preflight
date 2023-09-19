#!/bin/bash

preflight_checks() {
  kubectl version
  sh -c "$(curl -sSL https://git.io/install-kubent)"
}

fetch_metrics_server() {
  kubectl describe apiservice/v1beta1.metrics.k8s.io
  if [[ $? == 0 ]]; then
      echo "API metrics.k8s.io is provided by a service. Your autoscaling configurations based on resource metrics will work !"
  else
      echo "No service provide metrics.k8s.io. Be aware that autoscaling based on resource metrics will not work"
  fi
}

preflight_checks
fetch_metrics_server