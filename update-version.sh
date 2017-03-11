#!/bin/bash

# Grab the latest version from the os.json
NESSUS_VERSION=$(curl -ssl -o - "https://www.tenable.com/plugins/os.json" | jq .version)

# Replace the version in the Dockerfile
sed -i '/ENV NESSUS_VERSION=.*/c\ENV NESSUS_VERSION='${NESSUS_VERSION} Dockerfile
