[![Build Status](https://travis-ci.org/fabiand/kubectl-plugin-pvc.svg?branch=master)](https://travis-ci.org/fabiand/kubectl-plugin-pvc)

A simple [kubectl binary](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/)
(binary, ha!) plugin to create and optionally populate PVCs.

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

### Create and (optionally) upload

```bash
$ kubectl plugin pvc create my-data 10Gi README.md README.md
```

In order to create a new PVC called `fedora` with a size of _10Gi_ and copy the
local `README.md` into a file called `README.md` on the new PVC.

### Upload

```bash
$ kubectl plugin pvc cp my-data README.md README.md
```

### Cat contents

```bash
$ kubectl plugin pvc cat my-data README.md
```

