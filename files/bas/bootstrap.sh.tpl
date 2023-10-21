#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Start bootstrap script"
sudo apt-get update -y
sudo apt-get install net-tools -y
sudo apt-get install unzip -y

# Golang 1.19 install
echo "Installing Golang 1.19"
sudo wget  https://go.dev/dl/go1.19.linux-amd64.tar.gz 
sudo tar -C /usr/local/ -xvf go1.19.linux-amd64.tar.gz  
echo "export GOROOT=/usr/local/go" >> /home/ubuntu/.profile
echo "export GOPATH=$HOME/go" >> /home/ubuntu/.profile 
echo "export PATH=$PATH:/usr/local/go/bin" >> /home/ubuntu/.profile

# Caldera install
echo "Installing Caldera"
echo "Installing some packages for Caldera"
sudo adduser --system --no-create-home --group caldera
sudo apt-get install -y apt-transport-https ca-certificates gnupg2 
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa --yes
sudo apt install upx -y
sudo apt install python3.9 -y
sudo apt install python3-pip -y
# Upgrade pyOpenSSL - weird issue only impacting AWS EC2 AMI images
sudo pip3 install --upgrade pyOpenSSL

# Downloading Caldera
echo "Downloading Caldera"
cd /opt
sudo git clone https://github.com/mitre/caldera.git --recursive

# Get caldera.service 
echo "Get caldera.service"
file="caldera.service"
object_url="https://${s3_bucket}.s3.${region}.amazonaws.com/$file"
echo "Downloading s3 object url: $object_url"
for i in {1..5}
do
    echo "Download attempt: $i"
    curl "$object_url" -o /opt/caldera/caldera.service

    if [ $? -eq 0 ]; then
        echo "Download successful."
        break
    else
        echo "Download failed. Retrying..."
    fi
done

# Get default.yml 
echo "Get default.yml"
file="default.yml"
object_url="https://${s3_bucket}.s3.${region}.amazonaws.com/$file"
echo "Downloading s3 object url: $object_url"
for i in {1..5}
do
    echo "Download attempt: $i"
    curl "$object_url" -o /opt/caldera/local.yml

    if [ $? -eq 0 ]; then
        echo "Download successful."
        break
    else
        echo "Download failed. Retrying..."
    fi
done

cd /opt/caldera
sudo pip3 install -r requirements.txt
cp /opt/caldera/caldera.service /etc/systemd/system/caldera.service
cp /opt/caldera/local.yml /opt/caldera/conf/local.yml

# Download abilities zip
echo "Get abilities.zip"
file="abilities.zip"
object_url="https://${s3_bucket}.s3.${region}.amazonaws.com/$file"
echo "Downloading s3 object url: $object_url"
for i in {1..5}
do
    echo "Download attempt: $i"
    curl "$object_url" -o /opt/caldera/abilities.zip

    if [ $? -eq 0 ]; then
        echo "Download successful."
        break
    else
        echo "Download failed. Retrying..."
    fi
done
# unzip abilities
sudo unzip /opt/caldera/abilities.zip -d /opt/caldera/data/abilities/

# Download payloads zip
echo "Get payloads.zip"
file="payloads.zip"
object_url="https://${s3_bucket}.s3.${region}.amazonaws.com/$file"
echo "Downloading s3 object url: $object_url"
for i in {1..5}
do
    echo "Download attempt: $i"
    curl "$object_url" -o /opt/caldera/payloads.zip

    if [ $? -eq 0 ]; then
        echo "Download successful."
        break
    else
        echo "Download failed. Retrying..."
    fi
done
# unzip payloads
sudo unzip /opt/caldera/payloads.zip -d /opt/caldera/data/payloads/

sudo chown -R caldera:caldera /opt/caldera
sudo chmod 644 /etc/systemd/system/caldera.service
sudo systemctl daemon-reload
sudo systemctl enable caldera
sudo systemctl start caldera
# end of Caldera install

#VECTR install
echo "Installing VECTR"
sudo apt-get install -y ca-certificates curl gnupg unzip lsb-release 
sudo mkdir -p /etc/apt/keyrings
# Installing docker needed by VECTR
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
# Download VECTR Runtime
mkdir -p /opt/vectr
cd /opt/vectr
wget https://github.com/SecurityRiskAdvisors/VECTR/releases/download/ce-8.8.1/sra-vectr-runtime-8.8.1-ce.zip 
unzip sra-vectr-runtime-8.8.1-ce.zip
# Get the .env with correct variables
# Get default.yml
echo "Get vector .env"
file="vectr_env"
object_url="https://${s3_bucket}.s3.${region}.amazonaws.com/$file"
echo "Downloading s3 object url: $object_url"
for i in {1..5}
do
    echo "Download attempt: $i"
    curl "$object_url" -o /opt/vectr/vectr_env

    if [ $? -eq 0 ]; then
        echo "Download successful."
        break
    else
        echo "Download failed. Retrying..."
    fi
done
#copy the vectr_env to .env
cp /opt/vectr/vectr_env /opt/vectr/.env
# Start docker containers
echo "Start vectr containers"
sudo docker compose up -d 

# Install Prelude Operator Headless
mkdir /opt/prelude
chmod 0755 /opt/prelude
curl --location 'https://download.prelude.org/latest?arch=x64&platform=linux&variant=zip&edition=headless' -o /opt/prelude/headless.zip
cd /opt/prelude
unzip headless.zip
# Get operator.service 
echo "Get operator.service"
file="operator.service"
object_url="https://${s3_bucket}.s3.${region}.amazonaws.com/$file"
echo "Downloading s3 object url: $object_url"
for i in {1..5}
do
    echo "Download attempt: $i"
    curl "$object_url" -o /opt/prelude/operator.service

    if [ $? -eq 0 ]; then
        echo "Download successful."
        break
    else
        echo "Download failed. Retrying..."
    fi
done

# copy service file
cp /opt/prelude/operator.service /etc/systemd/system/operator.service
sudo chmod 644 /etc/systemd/system/operator.service
sudo systemctl daemon-reload
sudo systemctl enable operator 
sudo systemctl start operator 

echo "End of bootstrap script"
