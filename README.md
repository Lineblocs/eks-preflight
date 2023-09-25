# Lineblocs EKS preflight

This chart is a tool that asserts compatibility between an EKS cluster and lineblocs charts.

The structure is :

```bash
├── charts # Subcharts location
├── Chart.yaml
├── checks # Scripts used in k8s Jobs to assert compatibility. Will be loaded by Helm with {{ .Files ... }}
│   ├── cloudwatch.sh
│   ├── crds.sh
│   ├── csi.sh
│   ├── kubent.sh
│   ├── metrics.sh
│   └── etc...
├── README.md
├── templates # K8S resources (Jobs, ConfigMap, ...) that will run the tests. 
│   ├── configmap-cloudwatch.yml
│   ├── configmap-crds.yml
│   ├── configmap-csi.yml
│   ├── configmap-kubent.yml
│   ├── configmap-metrics.yml
│   ├── _helpers.tpl
│   ├── job-cloudwatch.yml
│   ├── job-crds.yml
│   ├── job-csi.yml
│   ├── job-kubent.yml
│   ├── job-metrics.yml
│   ├── NOTES.txt
│   ├── rbac.yml
│   └── etc...
└── values.yaml # Default values for a release. Feel free to create your own !
```

## Prerequisites

First, you will need an [AWS account](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html)
and [AWS CLI set up](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

After that, you will need [Helm](https://helm.sh/docs/intro/install/).

## Usage

To deploy these checks, you can run :

```bash
helm upgrade --install -f values.yaml <release_name> . -n <namespace>
```

Of course, you need to replace words surrounded by <>. Feel free to customize it, so it fits your needs.
You can also copy values.yaml and create new values with different settings. It will merge your new values with the
default one.

## Checks

### CloudWatch

*File*: cloudwatch.sh

It checks if CloudWatch related resources are present in the cluster.
It will run ```kubectl get ds``` and search for the corresponding CloudWatch resources.
An agent for metrics and,if set, a fluentd will be needed to pass the check.

**Searched resources**: DaemonSets

### CustomResourceDefinitions

*File*: crds.sh

It checks if the crds listed in helm values matches their desired version.

**Searched resources**: CustomResourceDefinitions

### CSIDrivers

*File*: csi.sh

This check is a bit more complex than the others. It has four modes :

1. ATLEASTONE: will make sure that at least one driver is present
2. REGEX: will compare the result of a ```kubectl get``` against a regex (output format is <csidriver1_name> <
   csidriver2_name> ...).
3. ONEPRESENT: not implemented yet
3. ALLPRESENT: not implemented yet

**Searched resources**: CSIDrivers

### Kubent

*File*: kubent.sh

This check runs [kubent](https://github.com/doitintl/kube-no-trouble) in the cluster to find resources in deprecated
APIs.

**Searched resources**: All kinds

### Metrics API

*File*: metrics.sh

This check will make sure that the metrics API is backed by a service. It can be
k8s [metrics-server](https://github.com/kubernetes-sigs/metrics-server), a Prometheus or anything else.

**Searched resources**: APIServices

### Extending

You can add more checks by creating a new script in `checks/` folder. Don't forget to add the configmap and the job
in `templates/` folder. Then reference some default values and we are good to go. Inspire yourself from existing checks,
the documentation should be clear enough for you to understand everything.

## Default values

| Name                       | Description                                                                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `checks_crds             ` | CRDs checks conf                                                                                                                                    |
| `checks_crds.enabled     ` | Do we check CRDs ?                                                                                                                                  |
| `checks_crds.crds        ` | List of (name, version) object to describe which CRDs to check and what version is required                                                         |
| `check_csi               ` | CSIDrivers checks conf                                                                                                                              |
| `check_csi.enabled       ` | Do we check CSIDrivers ?                                                                                                                            |
| `check_csi.checkMode     ` | One of the four modes of CSIDrivers check. Can be ATLEASTONE, REGEX (not implemented), ONEPRESENT (not implemented) or ALLPRESENT (not implemented) |
| `check_csi.csi           ` | If mode is ONEPRESENT or ALLPRESENT, is a list of CSI drivers needed.                                                                               |
| `check_kubent            ` | Kubent (deprecated resources) checks conf                                                                                                           |
| `check_kubent.enabled    ` | Do we check deprecated resources ?                                                                                                                  |
| `check_metrics           ` | Metrics API checks conf                                                                                                                             |
| `check_metrics.enabled   ` | Do we check deprecated resources ?                                                                                                                  |
| `check_cloudwatch        ` | CloudWatch resources checks conf                                                                                                                    |
| `check_cloudwatch.enabled` | Do we check deprecated resources ?                                                                                                                  |