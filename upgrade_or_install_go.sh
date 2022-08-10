#!/bin/bash

FILENAME="go1.19.linux-amd64.tar.gz"
URL="https://go.dev/dl/$FILENAME"
DOWNLOADS="$HOME/Downloads/"

if [ -d "/usr/local/go" ]; then
  ## remove old go installation
  rm -rf /usr/local/go
else
  {
    echo -e "\n# export go system settings"
    echo "export GOROOT=/usr/local/go"
    echo "export GOPATH=\$HOME/Dev/go"
    echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin"
    echo "export GOPRIVATE=github.com/fomo-labs"
  } >>/etc/profile
fi

# download and install new version
(cd "$DOWNLOADS" && curl -OL $URL) && tar -C /usr/local -xzf "$DOWNLOADS$FILENAME"
