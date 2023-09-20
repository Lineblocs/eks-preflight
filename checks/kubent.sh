#!/bin/bash

# preflight_checks will check if requirements for this check are met.
# This one will also install kubent.
preflight_checks() {
  apt update
  apt install -y curl
  kubectl version > /dev/null
  sh -c "$(curl -sSL https://git.io/install-kubent)" > /dev/null
}

# kubent_run checks if kubent command returns any deprecations in the cluster.
# Returns with 0 if present, 1 if not.
kubent_run() {
  if ! OUTPUT="$(kubent 2> /dev/null)"; then       # check for non-zero return code first
    echo "kubent failed to run!"
    exit 1
  elif [ -n "${OUTPUT}" ]; then       # check for empty stdout
    echo "Deprecated resources found"
    exit 0
  else
    echo "No deprecation where found !"
  fi
}

preflight_checks
kubent_run