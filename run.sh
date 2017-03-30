#!/bin/bash

set -e

if [ -z ${PLUGIN_NAMESPACE} ]; then
  PLUGIN_NAMESPACE="default"
fi

if [ ! -z ${PLUGIN_KUBERNETES_TOKEN} ]; then
  KUBERNETES_TOKEN=$PLUGIN_KUBERNETES_TOKEN
fi

if [ ! -z ${PLUGIN_KUBERNETES_SERVER} ]; then
  KUBERNETES_SERVER=$PLUGIN_KUBERNETES_SERVER
fi

if [ ! -z ${PLUGIN_KUBERNETES_CERT} ]; then
  KUBERNETES_CERT=${PLUGIN_KUBERNETES_CERT}
fi

kubectl config set-credentials default --token=${KUBERNETES_TOKEN}
if [ ! -z ${KUBERNETES_CERT} ]; then
  echo ${KUBERNETES_CERT} | base64 -d > ca.crt
  kubectl config set-cluster default --server=${KUBERNETES_SERVER} --certificate-authority=ca.crt
else
  echo "WARNING: Using insecure connection to cluster"
  kubectl config set-cluster default --server=${KUBERNETES_SERVER} --insecure-skip-tls-verify=true
fi

kubectl config set-context default --cluster=default --user=default
kubectl config use-context default

echo "Running the ${PLUGIN_JOB} job in the ${PLUGIN_NAMESPACE} namespace..."
kubectl --namespace=${PLUGIN_NAMESPACE} create -f "${PLUGIN_SPEC}"

echo "Waiting for the job to finish..."
while [ true ]; do
  result=`kubectl --namespace=${PLUGIN_NAMESPACE} get job/${PLUGIN_JOB} -o json | jq '.status.succeeded'`
  if [[ $result == "1" ]]; then
    break
  else
    sleep 1
  fi
done

echo "Deleting the job..."
kubectl --namespace=${PLUGIN_NAMESPACE} delete -f "${PLUGIN_SPEC}"
