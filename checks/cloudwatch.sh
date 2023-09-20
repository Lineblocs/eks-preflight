#!/bin/bash

# preflight_checks will check if requirements for this check are met.
preflight_checks() {
  kubectl version
}

# check_cloudwatch_presence checks if CloudWatch resources are found in the whole cluster.
# It searches for a daemonset named cloudwatch-agent.
# Returns with 0 if present, 1 if not.
check_cloudwatch_presence() {
  kubectl get ds -o=jsonpath='{.items[*].metadata.name}' -A | grep -w 'cloudwatch-agent' > /dev/null
  if [[ $? == 0 ]]; then
      echo "CloudWatch agent is present in the cluster !"
      exit 0
  else
      echo "CloudWatch is not present in the cluster"
      exit 1
  fi
}

# check_cloudwatch_presence checks if fluentd resources are found in the whole cluster.
# It searches for a daemonset named fluentd-cloudwatch.
# Returns with 0 if present, 1 if not.
# NOT READY yet
check_fluentd_presence() {
  kubectl get ds -o=jsonpath='{.items[*].metadata.name}' -A | grep -w 'fluentd-cloudwatch' > /dev/null
  if [[ $? == 0 ]]; then
        echo "Fluentd is present in the cluster !"
        return 0
    else
        echo "Fluentd is not present in the cluster"
        return 1
    fi
}

#if [ "$CHECK_FLUENTD" != "" ]; then
#  code=$(($(check_cloudwatch_presence) + $(check_fluentd_presence)))
#  exit $code
#else
#  code=$(check_cloudwatch_presence)
#  exit $code
#fi

check_cloudwatch_presence