#! /bin/bash
set -e  # Exit immediately on errors

echo "==== [INFO]...Updating OS packages ===="
sudo yum update -y

echo "==== [INFO]...Setting hostname to jenkins-server ===="
sudo hostnamectl set-hostname jenkins-server

echo "==== [INFO]...Installing Git ===="
sudo yum install git -y

echo "==== [INFO]...Installing Java 17 & dependencies for Jenkins ===="
sudo yum install java-17-amazon-corretto-devel -y
sudo java -version


echo "====[INFO]... Installing Jenkins ===="
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "==== [INFO]...Enabling and starting Jenkins ===="
sudo systemctl daemon-reload
sudo systemctl enable --now jenkins

echo "====[INFO]... Installing Docker ===="
sudo dnf install -y docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

echo "====[INFO]... Configuring Docker socket for local TCP access ===="
DOCKER_SERVICE_FILE="/lib/systemd/system/docker.service"
if ! grep -q "tcp://127.0.0.1:2375" "$DOCKER_SERVICE_FILE"; then
    sudo cp $DOCKER_SERVICE_FILE ${DOCKER_SERVICE_FILE}.bak
    sudo sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/dockerd -H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock|' $DOCKER_SERVICE_FILE
    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi

echo "==== [INFO]...Installing Docker Compose v2 ===="
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 \
    -o $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "====[INFO]... Installing AWS CLI v2 ===="
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip -o awscliv2.zip 
sudo ./aws/install --update 
sudo rm -rf aws awscliv2.zip


echo "====[INFO]... Installing Python 3, Ansible, and Boto3 ===="
sudo yum update
sudo yum install ansible.noarch python3-boto3.noarch -y

echo "===[INFO]...= Installing Terraform ===="
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

echo "====[INFO]... Restarting Jenkins ===="
sudo systemctl restart jenkins

echo "====[INFO]... Setup complete! ===="
echo "NOTE:[INFO]... Please reboot the instance to apply docker group changes:"
echo " [INFO]... rebooting my server"
sudo reboot 