#!/usr/bin/env bash

function setup(){
  echo "Creating cluster kubernetes"
  terraform init
  terraform apply -auto-approve
  kubectl apply -f ./kubernetes/000-namespace.yaml --kubeconfig=./kubeconfig.yaml 
  kubectl config set-context --current --namespace=transparent-namespace --kubeconfig=./kubeconfig.yaml
}

function storage(){
  kubectl get sc
  git clone https://github.com/digitalocean/container-blueprints.git
  cd container-blueprints/DOKS-Wordpress/
  helm repo add openebs-nfs https://openebs-archive.github.io/dynamic-nfs-provisioner
  helm repo update
  helm install openebs-nfs openebs-nfs/nfs-provisioner --version 0.9.0 --namespace openebs --create-namespace -f "assets/manifests/openEBS-nfs-provisioner-values.yaml"
  helm ls -n openebs
  kubectl apply -f "assets/manifests/sc-rwx-values.yaml"
  kubectl  get sc
}

function database(){
  # Documentation needed for the oficial website. Change hardcoded values. Simple PoC
  doctl databases create wordpress-mysql --engine mysql --region lon1 --num-nodes 2 --size db-s-2vcpu-4gb
  doctl databases list
  doctl databases user create cb317937-0505-40b6-875e-72e118cd9ae2 wordpress_user
  doctl databases db create cb317937-0505-40b6-875e-72e118cd9ae2 wordpress
  doctl kubernetes cluster list
  doctl databases firewalls append cb317937-0505-40b6-875e-72e118cd9ae2 --rule k8s:
  doctl databases create wordpress-redis --engine redis --region lon1 --num-nodes 1 --size db-s-1vcpu-1gb
  doctl databases firewalls append cb317937-0505-40b6-875e-72e118cd9ae2 --rule k8s:7ec9fec4-5698-4569-974b-3cbfb0f5a618
}

function wordpress(){
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update bitnami
  helm upgrade final-wordpress bitnami/wordpress --version 24.0.7 --namespace wordpress --atomic --install --values assets/manifests/wordpress-values.yaml
}

function nginx(){
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update ingress-nginx
  helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.1.3 --namespace ingress-nginx --create-namespace 
  helm ls -n ingress-nginx
  doctl compute load-balancer list --format IP,ID,Name,Status
#  doctl compute domain create myfirstdomain.co
}


setup
storage
database
wordpress
#nginx