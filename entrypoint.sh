#!/bin/bash

# Set variables
SFTP_HOST="$1"
SFTP_PORT="$2"
SFTP_USER="$3"
SSH_PRIVATE_KEY="$4"
REMOTE_PATH="$5"

if [ -z "$SFTP_HOST" ]; then
    echo "SFTP_HOST is not set. Quitting."
    exit 1
fi

if [ -z "$SFTP_PORT" ]; then
    echo "SFTP_PORT is not set. Falling back to default port 22."
    SFTP_PORT=22
fi

if [ -z "$SFTP_USER" ]; then
    echo "SFTP_USER is not set. Quitting."
    exit 1
fi

if [ -z "$SSH_PRIVATE_KEY" ]; then
    echo "SSH_PRIVATE_KEY is not set. Quitting."
    exit 1
fi

if [ -z "$REMOTE_PATH" ]; then
    echo "REMOTE_PATH is not set. Quitting."
    exit 1
fi

# Create SSH directory and set permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Write SSH private key to a file
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Disable strict host key checking
echo -e "Host $SFTP_HOST\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
chmod 600 ~/.ssh/config

# add all files to the safe directory
git config --global --add safe.directory '*'

# Get the list of changed and new files
git diff --name-only --diff-filter=ACMRT $GITHUB_SHA~1 $GITHUB_SHA > changed_files.txt

if [ ! -s changed_files.txt ]; then
    echo "No files to upload."
    rm changed_files.txt
    exit 0
fi

# Upload changed and new files via SFTP
lftp -d -c "set sftp:auto-confirm yes; set net:timeout 10; open -u $SFTP_USER, -p $SFTP_PORT -e 'set mirror:use-pget-n 10; cd $REMOTE_PATH; mirror -R --delete --only-newer --exclude .git/ --exclude .github/ -P1 --parallel=10 -x changed_files.txt .' sftp://$SFTP_HOST"

# Clean up
rm changed_files.txt

exit 0
