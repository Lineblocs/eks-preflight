#!/bin/bash

LB_MANIFESTS=./loadbalancer-manifests.yaml

# preflight_checks will check if requirements for this check are met.
preflight_checks() {
  kubectl version
  if [[ -z "$TESTING_NS" ]]; then
    echo "Please provide a TESTING_NS env var."
    exit 1
  fi

  if [[ ! -f "$LB_MANIFESTS" ]]; then
    echo "LB manifests could not be found at $LB_MANIFESTS..."
    exit 1
  fi
}

check_loadbalancer_ip_assignment() {
  kubectl apply -f "$LB_MANIFESTS" -n "$TESTING_NS"

  hostname=""
  retries=10
  until [[ -n $hostname || $retries == 0 ]]; do
    sleep 3
    hostname=$(kubectl get svc lb-checks -n "$TESTING_NS" --output="jsonpath={.status.loadBalancer.ingress[0].hostname}" || echo "Error during kubectl command..." >&2 && exit 1)
    ((retries-=1))
  done


  if [[ -z "$hostname" && $retries == 0 ]]; then
    echo "LoadBalancer service are not provisioned ..."
    exit 1
  else
    echo "LoadBalancer service are provisioned !"
    exit 0
  fi
}

preflight_checks
check_loadbalancer_ip_assignment