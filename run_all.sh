#/bin/bash

/run_wildfly.sh &

if [ "$RUN_WILDFLY_CONFIG" = true ]; then
  sleep $WAIT_FOR_WILDFLY_TO_RUN
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
fi

if [ "$ENABLE_GLOWROOT" = true ]; then
  bash /usr/local/wildfly/config_script/install_glowroot.sh
  echo "glowroot installed!"
fi

if [ "$DISABLE_MGMT_WEB_CONSOLE" = true ]; then
  bash /usr/local/wildfly/config_script/config_wildfly_disable_mgmt_web_console.sh
  echo "management console disabled!"
fi

if [ "$REMOVE_WF_WELCOME_CONTENT" = true ]; then
  bash /usr/local/wildfly/config_script/config_wildfly_remove_welcome_content.sh
  echo "wildfly welcome content removed!"
fi


## set signserver envi
source /etc/profile.d/envi_signserver.sh

# deploy
cd /opt/$SIGNSERVER_VERSION
ant deploy

sleep infinity
