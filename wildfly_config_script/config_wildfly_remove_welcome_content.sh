#!/bin/bash

# remove welcome content
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/host=default-host/location="\/":remove()'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/configuration=handler/file=welcome-content:remove()'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'

## remove to save disk space
rm -rf /opt/wildfly/welcome-content/
