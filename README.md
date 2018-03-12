[![Build Status](https://travis-ci.org/fabiand/kubectl-plugin-pvc.svg?branch=master)](https://travis-ci.org/fabiand/kubectl-plugin-pvc)

A simple [kubectl binary](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/)
(ha!) plugin to create and optionally populate PVCs.

This is very handy in the KubeVirt context in order to upload local virtual
machine images into the cluster.

## Installation

Without cloning the repo, on your client:

```bash
curl -L https://github.com/fabiand/kubectl-plugin-pvc/raw/master/install.sh | bash
```

Or: After cloning the repo, On your client:

```bash
$ bash install.sh
```

## Usage

### Create and upload

```bash
$ kubectl plugin pvc create fedora 10Gi fedora.img disk.img
```

In order to create a new PVC called `fedora` with a size of _10Gi_ and copy the
local `fedora.img` into a file called `disk.img` (required for KubeVirt) on
the new PVC.

### Cat contents

```bash
$ kubectl plugin pvc cat fedora disk.img
```

