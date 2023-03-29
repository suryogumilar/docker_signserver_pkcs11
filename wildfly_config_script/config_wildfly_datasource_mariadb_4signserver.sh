#!/bin/bash

wget https://dlm.mariadb.com/1785291/Connectors/java/connector-java-2.7.4/mariadb-java-client-2.7.4.jar -O /opt/wildfly/standalone/deployments/mariadb-java-client.jar


## Add a Datasource

/opt/wildfly/bin/jboss-cli.sh --connect '/subsystem=elytron/credential-store=defaultCS:add-alias(alias=dbPassword, secret-value="passw0rd")'
/opt/wildfly/bin/jboss-cli.sh --connect 'data-source add --name=signserverds --connection-url="jdbc:mysql://wfmariadb:3306/signserverdb" --jndi-name="java:/SignServerDS" --use-ccm=true --driver-name="mariadb-java-client.jar" --driver-class="org.mariadb.jdbc.Driver" --user-name="signserver" --credential-reference={store=defaultCS, alias=dbPassword} --validate-on-match=true --background-validation=false --prepared-statements-cache-size=50 --share-prepared-statements=true --min-pool-size=5 --max-pool-size=150 --pool-prefill=true --transaction-isolation=TRANSACTION_READ_COMMITTED --check-valid-connection-sql="select 1;"'
/opt/wildfly/bin/jboss-cli.sh --connect ':reload'
