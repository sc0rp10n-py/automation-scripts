#!/bin/sh

#./deploy.sh <repoName> <username> <password> <pm2Name> <ipAddress>

repo=$1
username=$2
pass=$3
pm2Name=$4
ipAddress=$5
echo "repo: $repo"
echo "username: $username"
# echo "pass: $pass"
echo "pm2Name: $pm2Name"
echo "ipAddress: $ipAddress"

# installing nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install node

npm i -g pm2

sudo apt install -y nginx

sudo systemctl restart nginx

sudo systemctl enable nginx

# install mongodb
sudo apt-get install gnupg curl

curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

sudo apt-get update

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo systemctl start mongod

sudo systemctl status mongod

sudo systemctl enable mongod

sudo systemctl restart mongod

git clone https://$username:$pass.github.com/$username/$repo.git

cd $repo

npm i

npm run build

pm2 start npm --name $pm2Name -- start

pm2 save

pm2 startup

sudo rm /etc/nginx/sites-enabled/default

sudo touch /etc/nginx/sites-available/$pm2Name

sudo ln -s /etc/nginx/sites-available/$pm2Name /etc/nginx/sites-enabled/$pm2Name

echo "server {listen 80;listen [::]:80;server_name $ipAddress;location / {proxy_pass http://localhost:3001;proxy_http_version 1.1;proxy_set_header Upgrade \$http_upgrade;proxy_set_header Connection 'upgrade';proxy_set_header Host \$host;proxy_cache_bypass \$http_upgrade;}}" > /etc/nginx/sites-available/$pm2Name

sudo nginx -t

sudo systemctl restart nginx
