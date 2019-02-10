# Pull base image.
FROM ubuntu:latest

RUN \
# Update
apt-get update -y && \
# Install Unzip
apt-get install unzip -y && \
# need wget
apt-get install wget -y

# Download terraform for linux
RUN wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip

# Unzip
RUN unzip terraform_0.11.10_linux_amd64.zip

# Move to local bin
RUN mv terraform /usr/local/bin/

# Check that it's installed
RUN terraform --version 