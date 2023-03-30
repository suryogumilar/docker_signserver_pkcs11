#/bin/bash

if [ ! "$RUN_WILDFLY_CONFIG" = true ]; then
  source /etc/profile.d/wildfly_setenv.sh
  
  if [ ! -f /opt/wildfly/standalone/deployments/mariadb-java-client.jar ]; then
    # deploy mariadb client jar

    wget https://dlm.mariadb.com/1785291/Connectors/java/connector-java-2.7.4/mariadb-java-client-2.7.4.jar\
     -O /opt/wildfly/standalone/deployments/mariadb-java-client.jar
  fi

  # create default keystore and keystore entry
  PATH_CONFIG_KEYSTORE=/opt/wildfly/standalone/configuration/keystore

  if [ ! -d "$PATH_CONFIG_KEYSTORE" ]; then
    echo "$PATH_CONFIG_KEYSTORE does not exist."
    mkdir -p /opt/wildfly/standalone/configuration/keystore
    chown wildfly:wildfly $PATH_CONFIG_KEYSTORE
  fi

  if [ ! -f /usr/bin/wildfly_pass ]; then

    # Create an Elytron Credential Store
    echo '#!/bin/sh' > /usr/bin/wildfly_pass
    echo "echo '$(openssl rand -base64 24)'" >> /usr/bin/wildfly_pass
    chown wildfly:wildfly /usr/bin/wildfly_pass
    chmod 700 /usr/bin/wildfly_pass
  fi
  
  if [ ! -f /opt/wildfly/standalone/configuration/keystore/credentials ]; then
    
    ## create credential store
    echo "create new credential store"
    elytron-tool.sh credential-store --create \
     --location /opt/wildfly/standalone/configuration/keystore/credentials \
     --password `/usr/bin/wildfly_pass`

    ## add alias entry -change this via envi variables
    elytron-tool.sh credential-store \
     --location /opt/wildfly/standalone/configuration/keystore/credentials \
     --password `/usr/bin/wildfly_pass` \
     --add httpsKeystorePassword --secret "$KEYSTORE_PASSWORD"

    elytron-tool.sh credential-store \
     --location /opt/wildfly/standalone/configuration/keystore/credentials \
     --password `/usr/bin/wildfly_pass` \
     --add httpsTruststorePassword --secret "$TRUSTSTORE_PASSWORD"
  
    elytron-tool.sh credential-store \
     --location /opt/wildfly/standalone/configuration/keystore/credentials \
     --password `/usr/bin/wildfly_pass` \
     --add dbPassword --secret "$DB_PASSWORD"
  fi

  unset DB_PASSWORD
  unset TRUSTSTORE_PASSWORD
  unset KEYSTORE_PASSWORD 

fi

if [ "$RUN_WILDFLY_CONFIG" = true ]; then
  echo "reset standalone.xml config"
  cp /opt/wildfly/standalone/configuration/standalone_init0.xml \
     /opt/wildfly/standalone/configuration/standalone.xml
fi

## run wildfly
/run_wildfly.sh &

## run config if set
if [ "$RUN_WILDFLY_CONFIG" = true ]; then
  sleep $WAIT_FOR_WILDFLY
  echo "undeploy signserver first"
  /opt/wildfly/bin/jboss-cli.sh --connect 'undeploy signserver.ear'
  ## run config scripts
  echo "config wildfly remoting"
  bash /usr/local/wildfly/config_script/config_wildfly_remoting.sh
  echo "config wildfly logging (for signserver)"
  bash /usr/local/wildfly/config_script/config_wildfly_signserver_logging.sh
  echo "config wsdl location rewrite"
  bash /usr/local/wildfly/config_script/config_wildfly_wsdl_location_rewrite.sh
  echo "config https 3port separation"
  bash /usr/local/wildfly/config_script/config_https_3port_separation.sh
  echo "remove exampe DS"
  bash /usr/local/wildfly/config_script/config_widlfy_remove_exampleDS.sh
  echo "config datasource mariadb"
  bash /usr/local/wildfly/config_script/config_wildfly_datasource_mariadb_4signserver.sh
else
  echo "waiting wildfly to up"
  sleep $WAIT_FOR_WILDFLY
fi

if [ "$ENABLE_GLOWROOT" = true ]; then
  bash /usr/local/wildfly/config_script/install_glowroot.sh
  echo "glowroot installed!"
  export ENABLE_GLOWROOT=false
fi

if [ "$DISABLE_MANAGEMENT_WEB_CONSOLE" = true ]; then
  bash /usr/local/wildfly/config_script/config_wildfly_disable_mgmt_web_console.sh
  echo "management console disabled!"
  export DISABLE_MANAGEMENT_WEB_CONSOLE=false
fi

if [[ ( "$REMOVE_WILDFLY_WELCOME_CONTENT" = true ) && ( -d /opt/wildfly/welcome-content ) ]]; then
  bash /usr/local/wildfly/config_script/config_wildfly_remove_welcome_content.sh
  echo "wildfly welcome content removed!"
  export REMOVE_WILDFLY_WELCOME_CONTENT=false
fi

## set signserver envi
source /etc/profile.d/envi_signserver.sh

if [[ (! -f /opt/wildfly/standalone/deployments/signserver.ear.deployed) || ("$RUN_WILDFLY_CONFIG" = true) ]]; then
  # deploy
  cd /opt/$SIGNSERVER_VERSION
  ant deploy
  echo "signserver deployed"
else
  echo "no deployment action taken since signserver already deployed"
fi

## cleaning up

if [ ! -f /etc/profile.d/unset_pass.sh ]; then
  echo "create unset_pass.sh"
  echo "#!/bin/bash" > /etc/profile.d/unset_pass.sh
  echo "unset DB_PASSWORD" >> /etc/profile.d/unset_pass.sh
  echo "unset TRUSTSTORE_PASSWORD" >> /etc/profile.d/unset_pass.sh
  echo "unset KEYSTORE_PASSWORD" >> /etc/profile.d/unset_pass.sh
fi

sleep infinity
