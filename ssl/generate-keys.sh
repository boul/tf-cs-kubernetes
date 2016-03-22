#!/bin/bash


mkdir /tmp/kube-ssl
# Generate Root CA
openssl genrsa -out /tmp/kube-ssl/ca-key.pem 2048
openssl req -x509 -new -nodes -key /tmp/kube-ssl/ca-key.pem -days 10000 -out /tmp/kube-ssl/ca.pem -subj "/CN=kube-ca"

# Generate API Servers Keys - needs openssl.cnf
openssl genrsa -out /tmp/kube-ssl/apiserver-key.pem 2048
openssl req -new -key /tmp/kube-ssl/apiserver-key.pem -out /tmp/kube-ssl/apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
openssl x509 -req -in /tmp/kube-ssl/apiserver.csr -CA /tmp/kube-ssl/ca.pem -CAkey /tmp/kube-ssl/ca-key.pem -CAcreateserial -out /tmp/kube-ssl/apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf

# Set vars for worker 1
WORKER_FQDN="kube-worker-1"
WORKER_IP="192.168.1.11"

export WORKER_IP="192.168.1.11"

#Generate keys for worker 1

openssl genrsa -out /tmp/kube-ssl/${WORKER_FQDN}-worker-key.pem 2048
openssl req -new -key /tmp/kube-ssl/${WORKER_FQDN}-worker-key.pem -out /tmp/kube-ssl/${WORKER_FQDN}-worker.csr -subj "/CN=${WORKER_FQDN}" -config worker-openssl.cnf
openssl x509 -req -in /tmp/kube-ssl/${WORKER_FQDN}-worker.csr -CA /tmp/kube-ssl/ca.pem -CAkey /tmp/kube-ssl/ca-key.pem -CAcreateserial -out /tmp/kube-ssl/${WORKER_FQDN}-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf

# Set vars for worker 2
WORKER_FQDN="kube-worker-2"
WORKER_IP="192.168.1.12"
export WORKER_IP="192.168.1.12"

#Generate keys for worker 2

openssl genrsa -out /tmp/kube-ssl/${WORKER_FQDN}-worker-key.pem 2048
openssl req -new -key /tmp/kube-ssl/${WORKER_FQDN}-worker-key.pem -out /tmp/kube-ssl/${WORKER_FQDN}-worker.csr -subj "/CN=${WORKER_FQDN}" -config worker-openssl.cnf
openssl x509 -req -in /tmp/kube-ssl/${WORKER_FQDN}-worker.csr -CA /tmp/kube-ssl/ca.pem -CAkey /tmp/kube-ssl/ca-key.pem -CAcreateserial -out /tmp/kube-ssl/${WORKER_FQDN}-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf

# Set vars for worker 3
WORKER_FQDN="kube-worker-3"
WORKER_IP="192.168.1.13"
export WORKER_IP="192.168.1.13"

#Generate keys for worker 3

openssl genrsa -out /tmp/kube-ssl/${WORKER_FQDN}-worker-key.pem 2048
openssl req -new -key /tmp/kube-ssl/${WORKER_FQDN}-worker-key.pem -out /tmp/kube-ssl/${WORKER_FQDN}-worker.csr -subj "/CN=${WORKER_FQDN}" -config worker-openssl.cnf
openssl x509 -req -in /tmp/kube-ssl/${WORKER_FQDN}-worker.csr -CA /tmp/kube-ssl/ca.pem -CAkey /tmp/kube-ssl/ca-key.pem -CAcreateserial -out /tmp/kube-ssl/${WORKER_FQDN}-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf
