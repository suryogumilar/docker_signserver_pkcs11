#!/bin/bash

# Remove Existing TLS and HTTP Configuration

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/http-listener=default:remove()'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/https-listener=https:remove()'
/opt/wildfly/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=http:remove()'
/opt/wildfly/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=https:remove()'
# These two lines are not needed if Galleon was used
/opt/wildfly/bin/jboss-cli.sh --connect '/core-service=management/security-realm=ApplicationRealm/server-identity=ssl:remove()'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'

# Add New Interfaces and Sockets

/opt/wildfly/bin/jboss-cli.sh --connect '/interface=http:add(inet-address="0.0.0.0")'
/opt/wildfly/bin/jboss-cli.sh --connect '/interface=httpspub:add(inet-address="0.0.0.0")'
/opt/wildfly/bin/jboss-cli.sh --connect '/interface=httpspriv:add(inet-address="0.0.0.0")'
/opt/wildfly/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=http:add(port="8080",interface="http")'
/opt/wildfly/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=httpspub:add(port="8442",interface="httpspub")'
/opt/wildfly/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=httpspriv:add(port="8443",interface="httpspriv")'


# Create an Elytron Credential Store

echo '#!/bin/sh' > /usr/bin/wildfly_pass
echo "echo '$(openssl rand -base64 24)'" >> /usr/bin/wildfly_pass
chown wildfly:wildfly /usr/bin/wildfly_pass
chmod 700 /usr/bin/wildfly_pass


# create default keystore and keystore entry

PATH_CONFIG_KEYSTORE=/opt/wildfly/standalone/configuration/keystore

if [ ! -d "$PATH_CONFIG_KEYSTORE" ]; then
  echo "$PATH_CONFIG_KEYSTORE does not exist."
  mkdir -p /opt/wildfly/standalone/configuration/keystore
fi

chown wildfly:wildfly $PATH_CONFIG_KEYSTORE

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/credential-store=defaultCS:add(location=keystore/credentials, relative-to=jboss.server.config.dir, credential-reference={clear-text="{EXT}/usr/bin/wildfly_pass", type="COMMAND"}, create=true)'



# Configure TLS

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/credential-store=defaultCS:add-alias(alias=httpsKeystorePassword, secret-value="foo123")'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/credential-store=defaultCS:add-alias(alias=httpsTruststorePassword, secret-value="foobar")'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/key-store=httpsKS:add(path="keystore/wildfly_keystore.p12",relative-to=jboss.server.config.dir,credential-reference={store=defaultCS, alias=httpsKeystorePassword},type=pkcs12)'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/key-store=httpsTS:add(path="keystore/truststore.jks",relative-to=jboss.server.config.dir,credential-reference={store=defaultCS, alias=httpsTruststorePassword},type=JKS)'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/key-manager=httpsKM:add(key-store=httpsKS,algorithm="SunX509",credential-reference={store=defaultCS, alias=httpsKeystorePassword})'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/trust-manager=httpsTM:add(key-store=httpsTS)'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/server-ssl-context=httpspub:add(key-manager=httpsKM,protocols=["TLSv1.3","TLSv1.2"],use-cipher-suites-order=false,cipher-suite-filter="TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256")'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/server-ssl-context=httpspriv:add(key-manager=httpsKM,protocols=["TLSv1.3","TLSv1.2"],use-cipher-suites-order=false,cipher-suite-filter="TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256",trust-manager=httpsTM,need-client-auth=true)'

# add https listener

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/http-listener=http:add(socket-binding="http", redirect-socket="httpspriv")'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/https-listener=httpspub:add(socket-binding="httpspub", ssl-context="httpspub", max-parameters=2048)'
/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/https-listener=httpspriv:add(socket-binding="httpspriv", ssl-context="httpspriv", max-parameters=2048)'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'


