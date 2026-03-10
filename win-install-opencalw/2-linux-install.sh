#!/bin/bash

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing dependencies..."
sudo apt install -y curl git build-essential

echo "Installing Node.js 20..."

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "Checking versions..."
node -v
npm -v

echo "Installing OpenClaw..."

sudo npm install -g openclaw

echo "Initializing OpenClaw..."

openclaw init

echo "Installation complete!"