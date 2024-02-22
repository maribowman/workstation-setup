#!/bin/bash

FILENAME="go1.19.linux-amd64.tar.gz"
URL="https://go.dev/dl/$FILENAME"
DOWNLOADS="$HOME/Downloads/"

if [ -d "/usr/local/go" ]; then
  # remove old go installation if exists
  sudo rm -rf /usr/local/go
else
  # append go system settings to profile
  cat <<EOF >> /etc/profile
  
  # export go system settings
  export GOROOT=/usr/local/go
  export GOPATH=\$HOME/go
  export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin
  export GOPRIVATE=github.com/fomo-labs
  EOF
fi

(cd "$DOWNLOADS" && curl -OL $URL) && sudo tar -C /usr/local -xzf "$DOWNLOADS/$FILENAME"
