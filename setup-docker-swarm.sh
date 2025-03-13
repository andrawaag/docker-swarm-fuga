#!/bin/bash
set -e
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
