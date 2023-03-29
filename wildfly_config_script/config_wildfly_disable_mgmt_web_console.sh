#!/bin/bash

# disable management web console
/opt/wildfly/bin/jboss-cli.sh --connect '/core-service=management/management-interface=http-interface:write-attribute(name=console-enabled,value=false)'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'
