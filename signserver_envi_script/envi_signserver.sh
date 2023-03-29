#!/bin/bash

## copy this file to /etc/profile.d also
## `cp ./envi_signserver.sh /etc/profile.d/envi_signserver.sh`
## and always run it after every restart to set envi

export APPSRV_HOME=/opt/wildfly
export SIGNSERVER_NODEID=node1

## old envi (signserver v5.2)
SIGNSERVER_HOME=/opt/signserver
export SIGNSERVER_HOME
export PATH=$SIGNSERVER_HOME/bin:$PATH
