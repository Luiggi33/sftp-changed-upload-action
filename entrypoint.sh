#!/bin/bash

# Set variables
SFTP_HOST="$1"
SFTP_USER="$2"
SSH_PRIVATE_KEY="$3"
REMOTE_PATH="$4"

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
git diff-tree --no-commit-id --name-only -r ${GITHUB_SHA} > changed_files.txt

echo "$SFTP_HOST:$REMOTE_PATH using $SFTP_USER"
echo "Files to upload:"
cat changed_files.txt

# Upload changed and new files via SFTP
lftp -d -c "set ftp:ssl-allow no; open -u $SFTP_USER,placeholder -e 'mirror -R --delete --only-newer --exclude-glob .git/ --exclude-glob .github/ --exclude-glob *.sh -P1 --parallel=10 -x changed_files.txt $REMOTE_PATH' $SFTP_HOST"

# Clean up
rm changed_files.txt
