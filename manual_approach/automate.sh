#!/usr/bin/env bash

function create_kubernetes_cluster() {
  echo "Creating cluster kubernetes"
  terraform init
  terraform apply -auto-approve
  kubectl apply -f ./kubernetes/000-namespace.yaml --kubeconfig=./kubeconfig.yaml 
  kubectl config set-context --current --namespace=testing-transparent-namespace --kubeconfig=./kubeconfig.yaml
}


function install_sealed_secrets(){
    # Install Helm if not already installed
    if ! command -v helm &> /dev/null
    then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi

    function install_kubeseal(){
        # Fetch the latest sealed-secrets version using GitHub API
        KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-)
        
        # Check if the version was fetched successfully
        if [ -z "$KUBESEAL_VERSION" ]; then
            echo "Failed to fetch the latest KUBESEAL_VERSION"
            exit 1
        fi
        
        curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
        tar -xvzf kubeseal-${kubeseal_version}-linux-amd64.tar.gz kubeseal
        sudo install -m 755 kubeseal /usr/local/bin/kubeseal
        rm ./kubeseal kubeseal-${kubeseal_version}-linux-amd64.tar.gz
    }

    # Install the Sealed Secrets controller
    helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --kubeconfig=./kubeconfig.yaml
    helm repo update --kubeconfig=./kubeconfig.yaml
    helm install sealed-secrets-controller sealed-secrets/sealed-secrets --namespace testing-transparent-namespace --kubeconfig=./kubeconfig.yaml


    # Wait for the controller to be available
    kubectl wait --namespace testing-transparent-namespace --for=condition=available deployment/sealed-secrets-controller --timeout=60s --kubeconfig=./kubeconfig.yaml

}


function create_sealed_secrets() {
  echo "Obtain the public key from the Sealed Secrets controller"
  kubeseal --kubeconfig=./kubeconfig.yaml --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=testing-transparent-namespace > sealed-secrets-cert.pem

  echo "Creating sealed secrets"
  cat << EOF > kubernetes/001-mysql-root-password.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-root-password
  namespace: testing-transparent-namespace
stringData:
  password: '$MYSQL_ROOT_PASSWORD'
EOF
  cat << EOF > kubernetes/002-mysql-database.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-database
  namespace: testing-transparent-namespace
stringData:
  password: '$MYSQL_DATABASE'
EOF
  cat << EOF > kubernetes/003-mysql-user.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-user
  namespace: testing-transparent-namespace
stringData:
  password: '$MYSQL_USER'
EOF
  cat << EOF > kubernetes/004-mysql-password.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-password
  namespace: testing-transparent-namespace
stringData:
  password: '$MYSQL_PASSWORD'
EOF
  cat << EOF > kubernetes/005-wordpress-db-host.yaml
apiVersion: v1
kind: Secret
metadata:
  name: wordpress-db-host
  namespace: testing-transparent-namespace
stringData:
  password: '$WORDPRESS_DB_HOST'
EOF
  cat << EOF > kubernetes/006-wordpress-db-user.yaml
apiVersion: v1
kind: Secret
metadata:
  name: wordpress-db-user
  namespace: testing-transparent-namespace
stringData:
  password: '$WORDPRESS_DB_USER'
EOF
  cat << EOF > kubernetes/007-wordpress-db-password.yaml
apiVersion: v1
kind: Secret
metadata:
  name: wordpress-db-password
  namespace: testing-transparent-namespace
stringData:
  password: '$WORDPRESS_DB_PASSWORD'
EOF
  cat << EOF > kubernetes/008-wordpress-db-name.yaml
apiVersion: v1
kind: Secret
metadata:
  name: wordpress-db-name
  namespace: testing-transparent-namespace
stringData:
  password: '$WORDPRESS_DB_NAME'
EOF

  # Seal the secrets
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/001-mysql-root-password.yaml > kubernetes/001-mysql-root-password-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/002-mysql-database.yaml > kubernetes/002-mysql-database-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/003-mysql-user.yaml > kubernetes/003-mysql-user-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/004-mysql-password.yaml > kubernetes/004-mysql-password-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/005-wordpress-db-host.yaml > kubernetes/005-wordpress-db-host-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/006-wordpress-db-user.yaml > kubernetes/006-wordpress-db-user-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/007-wordpress-db-password.yaml > kubernetes/007-wordpress-db-password-sealed.yaml
  kubeseal --kubeconfig=./kubeconfig.yaml --format yaml --cert sealed-secrets-cert.pem < kubernetes/008-wordpress-db-name.yaml > kubernetes/008-wordpress-db-name-sealed.yaml



  # Remove the unsealed Secret files
  rm kubernetes/001-mysql-root-password.yaml kubernetes/002-mysql-database.yaml kubernetes/003-mysql-user.yaml kubernetes/004-mysql-password.yaml kubernetes/005-wordpress-db-host.yaml kubernetes/006-wordpress-db-user.yaml kubernetes/007-wordpress-db-password.yaml kubernetes/008-wordpress-db-name.yaml 

  # Apply the Sealed Secrets to the cluster
  kubectl apply -f kubernetes/001-mysql-root-password-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/002-mysql-database-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/003-mysql-user-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/004-mysql-password-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/005-wordpress-db-host-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/006-wordpress-db-user-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/007-wordpress-db-password-sealed.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f kubernetes/008-wordpress-db-name-sealed.yaml --kubeconfig=./kubeconfig.yaml
}


function apply_kubernetes() {
  echo "Applying kubernetes manifests"
  sleep 40 
  kubectl --kubeconfig=./kubeconfig.yaml get all
  kubectl apply -f ./kubernetes/009-mysql-statefulset.yaml --kubeconfig=./kubeconfig.yaml 
  kubectl apply -f ./kubernetes/010-wordpress-statefulset.yaml --kubeconfig=./kubeconfig.yaml 
  kubectl apply -f ./kubernetes/011-rbac.yaml --kubeconfig=./kubeconfig.yaml
  kubectl apply -f ./kubernetes/012-role.yaml --kubeconfig=./kubeconfig.yaml
  kubectl get nodes --kubeconfig=./kubeconfig.yaml
  kubectl get pods --all-namespaces --kubeconfig=./kubeconfig.yaml
}


# Function to ensure all required environment variables are set
function verify_environment_variables() {
    # List of required environment variables
    required_variables=(
        "digitalocean_token"
        "MYSQL_ROOT_PASSWORD"
        "MYSQL_DATABASE"
        "MYSQL_USER"
        "MYSQL_PASSWORD"
        "WORDPRESS_DB_HOST"
        "WORDPRESS_DB_PASSWORD"
    )

    # Flag to track if any variables are missing
    missing_variables=0

    # Loop through the variables to check if they're set
    for var in "${required_variables[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: The environment variable '$var' is not set."
            missing_variables=1
        fi
    done

    # If any variables are missing, exit with an error
    if [ $missing_variables -eq 1 ]; then
        echo "Please ensure all required environment variables are configured before proceeding."
        exit 1
    else
        echo "All required environment variables are properly configured."
    fi
}

verify_environment_variables
create_kubernetes_cluster
install_sealed_secrets
create_sealed_secrets
apply_kubernetes