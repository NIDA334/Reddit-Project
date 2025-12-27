#!/bin/bash
set -e

echo "===== Updating system ====="
sudo apt update -y

echo "===== Installing Java 17 ====="
sudo apt install -y openjdk-17-jdk openjdk-17-jre
java --version

echo "===== Installing Jenkins ====="
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Installing Docker ====="
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

echo "===== Fixing Docker permission ====="
sudo chmod 666 /var/run/docker.sock

echo "===== Installing AWS CLI v2 ====="
sudo apt install unzip -y
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install
aws --version

echo "===== Installing kubectl ====="
curl -LO https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo "===== Installing Terraform ====="
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor \
-o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee \
/etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update -y
sudo apt install -y terraform
terraform version

echo "===== Installing Trivy ====="
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt update -y
sudo apt install -y trivy
trivy --version

echo "===== Preparing system for SonarQube ====="
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

echo "===== Running SonarQube Container ====="
docker run -d \
--name sonar \
-p 9000:9000 \
sonarqube:lts-community

echo "===== ALL TOOLS INSTALLED SUCCESSFULLY ====="
