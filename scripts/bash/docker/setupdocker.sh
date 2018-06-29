#!/bin/bash
# Created by:  Karl Vietmeier
### Install and configure Docker

# Install container bundle
yum install docker -y

# Start and enable Docker services
systemctl enable docker
systemctl start docker