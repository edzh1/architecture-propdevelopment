#!/bin/bash

USER1=dev-user
USER2=viewer-user

openssl genrsa -out ${USER1}.key 2048
openssl req -new -key ${USER1}.key -out ${USER1}.csr -subj "/CN=${USER1}/O=developers"
openssl x509 -req -in ${USER1}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${USER1}.crt -days 365

openssl genrsa -out ${USER2}.key 2048
openssl req -new -key ${USER2}.key -out ${USER2}.csr -subj "/CN=${USER2}/O=viewers"
openssl x509 -req -in ${USER2}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${USER2}.crt -days 365

CONTEXT=$(kubectl config current-context)
CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\\\"${CONTEXT}\\\")].context.cluster}")
SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\\\"${CLUSTER}\\\")].cluster.server}")

for USER in ${USER1} ${USER2}; do
  kubectl config set-credentials ${USER} --client-certificate=${USER}.crt --client-key=${USER}.key
  kubectl config set-context ${USER}-context --cluster=${CLUSTER} --namespace=default --user=${USER}
done