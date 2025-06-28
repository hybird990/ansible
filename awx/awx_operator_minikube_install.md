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

admin
7ksyioHHLN81lCcTD5Mw4sLM2QRYAFko


#Look for the port awx-demo-service is using

kubectl get svc

10.108.147.175 

#and replace 31592 with that port number

kubectl port-forward svc/awx-demo-service --address 0.0.0.0 31592:80

#open that port in a web browser

sudo systemctl disable --now firewalld


#Add a new manual source for awx - new project 
/var/lib/awx/projects
-----------------------------
docker ps #get name
docker exec -it minikube bash

    1  pwd
    2  cd /var/lib/awx
    3  pwd
    4  ls
    5  cd /var/
    6  ls
    7  cd lib/
    8  ls
    9  mkdir awx
   10  cd awx/
   11  ls
   12  mkdir projects
   13  cd projects/
   14  ls
   15  mkdir vcenter-playbooks
   16  cd vcenter-playbooks/
   17  ls
   18  history
   19  sudo nano vcenter_vars.yml
   20  nano vcenter_vars.yml
   21  vi vcenter_vars.yml


#awx process in gui
----------------------------
create org first
create team associate with org
create user associate with org and team
add creds under resource cred type VMware vcenter org duck - sso administrator@vsphere.local
add cred GitHub oersonal access token - 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
add creds under source control - git hub account
add inventory - vcenter associate to org
associate inventory with sources  VMware vcenter- 192.168.1.13, associate with sso
create project VMware, add org, git,
use public git address http https://github.com/hybird990/ansible.git
create a new template for job and select playbook
