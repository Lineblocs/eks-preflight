#!/bin/bash

# preflight_checks will check if requirements for this check are met.
preflight_checks() {
  kubectl version
}

# fetch_metrics_server checks if metrics.k8s.io API is provider by a service of any kind.
# It can be provided by metrics-server, by a Prometheus, ...
# Returns with 0 if present, 1 if not.
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

# TODO: check for custom metrics too ?