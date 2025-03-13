#!/bin/bash

# Script to automate Docker Swarm setup on Fuga.Cloud (Cyso Cloud)

# Exit on error
set -e

# Variables
MANAGER_IP="your-manager-ip"  # Replace with actual Manager Node IP
SWARM_JOIN_CMD_FILE="/tmp/swarm_join_cmd.txt"

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io

# Enable and start Docker service
echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Check if node is a manager or worker
if [ "$1" == "manager" ]; then
    echo "Initializing Docker Swarm on Manager Node..."
    docker swarm init --advertise-addr "$MANAGER_IP" > /dev/null 2>&1
    docker swarm join-token worker -q > "$SWARM_JOIN_CMD_FILE"
    echo "Swarm Manager setup complete."
    echo "Worker join command saved in $SWARM_JOIN_CMD_FILE"

elif [ "$1" == "worker" ]; then
    echo "Joining Swarm as Worker..."
    if [ -f "$SWARM_JOIN_CMD_FILE" ]; then
        SWARM_JOIN_CMD=$(cat "$SWARM_JOIN_CMD_FILE")
        docker swarm join --token "$SWARM_JOIN_CMD" "$MANAGER_IP:2377"
        echo "Worker joined Swarm."
    else
        echo "ERROR: Swarm join command not found! Run this on the Manager first."
        exit 1
    fi

else
    echo "Usage: $0 {manager|worker}"
    exit 1
fi
