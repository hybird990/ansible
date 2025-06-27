# AWX Operator Minikube Installation

## Install Docker
Install red hat 8 with mini install

#root
useradd -m ansible
passwd ansible
echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#switch to normal user
sudo dnf update -y
sudo dnf remove runc podman -y
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

logout and back in again

## Install kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

## Install and start minikube

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/


#Start Minikube

minikube start --addons=ingress --cpus=2 --install-addons=true --kubernetes-version=stable --memory=6g


#Check if it is working

kubectl get nodes
kubectl get pods
kubectl get pods -A

## Install AWX Operator

##Install prerequisites

sudo dnf install make git -y

##Get package and cd into directory:

git clone https://github.com/ansible/awx-operator.git
cd awx-operator/

#You can get a list of versions via

git tag

#We will use version 2.19.1

git checkout tags/2.19.1
export VERSION=2.19.1
make deploy

#create a new file called kustomization.yaml


cat << EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=2.19.1
  - awx-demo.yml

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.19.1
# Specify a custom namespace in which to install AWX
namespace: awx
EOF

#Change namespace to awx

kubectl config set-context --current --namespace=awx

#Finish configurations:

kubectl apply -k .

#Check settings progress

kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"

#Progress can also be checked via logs (can take some  time), there will be a status at the end:

kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager

#Find out admin password

kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode

admn
7ksyioHHLN81lCcTD5Mw4sLM2QRYAFko


#Look for the port awx-demo-service is using

kubectl get svc

10.108.147.175 

#and replace 31592 with that port number

kubectl port-forward svc/awx-demo-service --address 0.0.0.0 31592:80

#open that port in a web browser

sudo systemctl disable --now firewalld
