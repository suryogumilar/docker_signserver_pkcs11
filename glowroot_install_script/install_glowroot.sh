#!/bin/bash


## get glowroot
wget https://github.com/glowroot/glowroot/releases/download/v0.13.6/glowroot-0.13.6-dist.zip -O /tmp/glowroot.zip
unzip -q /tmp/glowroot.zip -d /opt/wildfly
chown -R wildfly:wildfly /opt/wildfly/glowroot

sed -i '/-Djdk.tls.ephemeralDHKeySize=2048/ a \ \ \ JAVA_OPTS=\"$JAVA_OPTS -javaagent:/opt/wildfly/glowroot/glowroot.jar"' /opt/wildfly/bin/standalone.conf
#systemctl restart wildfly
