#!/bin/bash

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=webservices:write-attribute(name=wsdl-host, value=jbossws.undefined.host)'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=webservices:write-attribute(name=modify-wsdl-address, value=true)'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'

