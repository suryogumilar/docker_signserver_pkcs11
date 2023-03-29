#/bin/bash

/run_wildfly.sh

sleep $WAIT_FOR_WILDFLY_TO_RUN

## run config scripts

bash /usr/local/wildfly/config_script/config_wildfly_remoting.sh
bash /usr/local/wildfly/config_script/config_wildfly_signserver_logging.sh
bash /usr/local/wildfly/config_script/config_wildfly_wsdl_location_rewrite.sh
bash /usr/local/wildfly/config_script/config_https_3port_separation.sh
bash /usr/local/wildfly/config_script/config_widlfy_remove_exampleDS.sh
bash /usr/local/widlfly/config_script/config_wildfly_datasource_mariadb_4signserver.sh

if [ "$ENABLE_GROWROOT" = true ]; then
  bash /usr/local/wildfly/config_script/install_glowroot.sh
  echo "glowroot enabled!"
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


