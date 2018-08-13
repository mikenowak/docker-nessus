#!/bin/bash

# Grab the latest version from the os.json
NESSUS_VERSION=$(NESSUS_VERSION=$(curl -ssl -o - "https://www.tenable.com/downloads/nessus" | sed -n -e 's/.*data-download-id="\([0-9]*\)".*data-file-name="\([a-zA-Z0-9_\.-]\+\-es7\.x86_64\.rpm\).*".*/\2/p' | awk -F- '{ print $2}')

# Replace the version in the Dockerfile
sed -i '/ENV NESSUS_VERSION=.*/c\ENV NESSUS_VERSION='${NESSUS_VERSION} Dockerfile
