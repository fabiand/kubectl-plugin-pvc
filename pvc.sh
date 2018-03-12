#!/bin/bash

usage() {
  CMD=$0
  [[ "$KUBECTL_PLUGINS_CALLER" ]] && CMD="kubectl plugin pvc"
  cat <<EOM
Usage: $CMD create PVCNAME SIZE [SRC DST]"

create -- This command will create a new PVC of the given name and size.
          Optionally it will copy SRC to DST (within the new PVC).

EOM
exit 1
}

fatal() { echo "FATAL: $@" >&2 ; exit 1 ; }

pvc_tpl() {
  local NAME=$1
  local SIZE=${2:10Gi}
  cat <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $NAME
spec:
  volumeMode: Filesystem
  resources:
    requests:
      storage: $SIZE
EOF
}

tpls() {
  local TPLS=$1
  local NAME=$2
  local SIZE=$3

  [[ "$TPLS" == *pvc* ]] && cat <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $NAME
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: $SIZE
---
EOF

  [[ "$TPLS" == *pod* ]] && cat <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: $PVCNAME
spec:
  terminationGracePeriodSeconds: 0
  containers:
    - name: busybox
      image: busybox
      command: ["/bin/sleep", "42"]
      volumeMounts:
      - mountPath: "/dst"
        name: dst
  volumes:
    - name: dst
      persistentVolumeClaim:
        claimName: $PVCNAME
---
EOF
}

wait_running() { until [[ "$(kubectl get pod $1 -o jsonpath='{.status.phase}')" == Running ]]; do sleep 1; done ; }

_create() {
  local PVCNAME=$1
  local SIZE=$2
  local SRC=$3
  local DST=$4

  set -e

  [[ "$PVCNAME" ]] || fatal "No PVC name given"
  [[ "$SIZE" ]] || fatal "No size given"

  kubectl get pvc $PVCNAME >/dev/null 2>&1 && fatal "PVC '$PVCNAME' already exists"
  kubectl get pod $PVCNAME >/dev/null 2>&1 && fatal "Pod '$PVCNAME' already exists"

  echo "Creating PVC"
  tpls pvc $PVCNAME $SIZE | kubectl create -f -

  [[ "$SRC" ]] && {
    [[ "$DST" ]] || fatal "No destination file given"
    echo "Populating PVC"
    tpls pod $PVCNAME $SIZE | kubectl create -f -
    wait_running $PVCNAME
    #kubectl get -o yaml pod $PVCNAME
    kubectl cp $SRC $PVCNAME:"/dst/$DST"
    kubectl exec $PVCNAME -- sh -c "cd dst && ls -shAl"

    echo "Cleanup"
    tpls pod $PVCNAME $SIZE | kubectl delete -f -
  }
}

_cat() {
  local PVCNAME=$1
  local FN=$2

  [[ "$PVCNAME" ]] || fatal "No PVC name given"
  kubectl get pvc $PVCNAME >/dev/null 2>&1 || fatal "PVC '$PVCNAME' does not exists"
  [[ "$FN" ]] || fatal "No filename given"

  tpls pod $PVCNAME | kubectl create -f - >&2
  wait_running $PVCNAME
  kubectl exec $PVCNAME -- sh -c "cd dst && cat $FN"
  tpls pod $PVCNAME | kubectl delete -f - >&2
}

main() {
  if [[ "$1" == create || "$1" == cat ]];
  then
    local CMD=_$1
    shift 1
    $CMD $@
  else
    fatal "Unknown command: $1"
  fi
}

if [[ ${#} == 0 || $@ == *-h* ]];
then
  usage
else
  main $@
fi
