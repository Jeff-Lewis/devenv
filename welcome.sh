#!/usr/bin/env bash

if [ ! -f /home/dev/credentials/id_rsa ]; then
    echo """
        /home/dev/credentials/id_rsa not found
        If you create a RSA key here we'll auto add it's identity on ssh
    """
else
    eval $(ssh-agent -s)
    ssh-add ~/credentials/id_rsa
fi

if [ ! -f /home/dev/credentials/aws ]; then
    echo """
        /home/dev/credentials/aws not found
        If you create a file with your aws credentials here we'll move it to the appropriate location
    """
else
    mkdir ~/.aws
    cp ~/credentials/aws ~/.aws/credentials
fi

echo """
   ___           ____        
  / _ \___ _  __/ __/__ _  __
 / // / -_) |/ / _// _ \ |/ /
/____/\__/|___/___/_//_/___/

Welcome to the development environment image.

Pre-installed packages:

aws-cli
go
node / nvm
protobuffs
python2 / pip
python3
"""
