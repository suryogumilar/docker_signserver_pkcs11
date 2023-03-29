#!/bin/bash

####
# SignServer needs to use JBoss Remoting for the SignServer Admin CLI to work. 
# Configure it to use a separate port 4447 and remove any other dependency on 
# remoting except for what SignServer needs.
######

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=remoting/http-connector=http-remoting-connector:write-attribute(name=connector-ref,value=remoting)'
/opt/wildfly/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=remoting:add(port=4447,interface=management)'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/http-listener=remoting:add(socket-binding=remoting,enable-http2=true)'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'
