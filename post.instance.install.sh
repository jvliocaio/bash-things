## install docker

sudo apt-get update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    unzip
    
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## install aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install

## post-install user steps
#sudo groupadd docker

mkdir .aws

echo "[default]
aws_access_key_id = ${AWS_KEY}
aws_secret_access_key = ${AWS_SECRET_KEY} > .aws/credentials

echo "[default]
region = us-east-2
output = json" > .aws/config

aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${AWS_IDENTIFY}

sudo usermod -aG docker $USER && newgrp docker



