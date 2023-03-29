#!/bin/bash

# remove example ds

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=ee/service=default-bindings:remove()'
/opt/wildfly/bin/jboss-cli.sh --connect 'data-source remove --name=ExampleDS'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'
