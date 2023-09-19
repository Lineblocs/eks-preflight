#!/bin/bash

preflight_checks() {
  kubectl version
}

check_cloudwatch_presence() {
  kubectl get ds -o=jsonpath='{.items[*].metadata.name}' -A | grep -w 'cloudwatch-agent' > /dev/null
  if [[ $? == 0 ]]; then
      echo "Cloudwatch agent is present in the cluster !"
  else
      echo "Cloudwatch is not present in the cluster"
  fi
}

check_fluentd_presence() {
  kubectl get ds -o=jsonpath='{.items[*].metadata.name}' -A | grep -w 'fluentd-cloudwatch' > /dev/null
  if [[ $? == 0 ]]; then
        echo "Fluentd is present in the cluster !"
    else
        echo "Fluentd is not present in the cluster"
    fi
}

check_cloudwatch_presence

if [ "$CHECK_FLUENTD" != "" ]; then
  check_fluentd_presence
fi