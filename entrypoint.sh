#!/bin/bash

# Set variables
SFTP_HOST="$1"
SFTP_PORT="$2"
SFTP_USER="$3"
SSH_PRIVATE_KEY="$4"
REMOTE_PATH="$5"

# Create SSH directory and set permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Write SSH private key to a file
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Set strict SSH key checking
echo "StrictHostKeyChecking no" > ~/.ssh/config

# add all files to the safe directory
git config --global --add safe.directory '*'

# Get the list of changed and new files
git diff-tree --no-commit-id --name-only -r $GITHUB_SHA > changed_files.txt

# Upload changed and new files via SFTP
lftp -d -c "set ftp:ssl-allow no; open -u $SFTP_USER,placeholder -p $SFTP_PORT -e 'cd $REMOTE_PATH; mirror -R --delete --only-newer --exclude-glob .git/ --exclude-glob .github/ -P1 --parallel=10 -x changed_files.txt .' $SFTP_HOST"

# Clean up
rm changed_files.txt
