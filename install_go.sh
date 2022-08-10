#!/bin/bash
curl -OL https://go.dev/dl/go1.19.linux-amd64.tar.gz

# remove old go installation and install new tar
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz

# TODO add to `/etc/profile`
echo "export GOROOT=/usr/local/go" >>/etc/.profile
echo "export GOPATH=$(HOME)/Dev/go" >>/etc/.profile
echo "export PATH=$PATH:$(GOROOT)/bin:$(GOPATH)/bin" >>/etc/.profile
echo "export GOPRIVATE=github.com/fomo-labs" >>/etc/.profile

#echo "export GOROOT=/usr/local/go" >>/test
#echo "export GOPATH=$(HOME)/Dev/go" >>/test
#echo "export PATH=$PATH:$(GOROOT)/bin:$(GOPATH)/bin" >>/test
#echo "export GOPRIVATE=github.com/fomo-labs" >>/test
