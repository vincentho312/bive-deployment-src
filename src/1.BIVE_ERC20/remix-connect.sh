#!/bin/bash

echo "Install Remixd"
npm install -g @remix-project/remixd

echo "Connect Remix IDE to localhost"
remixd -s $PWD/audit --remix-ide https://remix.ethereum.org
