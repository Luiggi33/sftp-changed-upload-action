# SFTP Upload GitHub Action

This GitHub Action allows you to automate the upload of changed and new files to an SFTP server using lftp.

## Current Status

This repository is currently in the working, you should not use it in the current state. Everything before v2 will probably be broken.

## Usage

To use this action, you need to include it as a step in your GitHub Actions workflow. Here's an example:

```yaml
name: SFTP Upload

on:
  push:
    branches:
      - main

jobs:
  upload:
    runs-on: ubuntu-latest

    steps:
    - name: Check Out Code
      uses: actions/checkout@v2

    - name: SFTP Upload
      uses: luiggi33/sftp-upload-action@v1
      with:
        sftp-host: ${{ secrets.SFTP_HOST }}
        sftp-port: 22
        sftp-user: ${{ secrets.SFTP_USER }}
        ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
        remote-path: path/on/remote/server
```
