# Signserver 5.11 docker version

using image created from [docker local build wildfly v26.1.2](https://github.com/suryogumilar/wildfly_docker/tree/wildfly_26_1_2) 

Applications used in this image are:
 - Almalinux 9.1
 - Wildfly version 26.1.2-Final   
   This is the default version, we can change it runtimely during build using 
   `--build-arg` e.g: `docker build --build-arg WILDFLY_VERSION=26.1.2-Final`
 - JDK java-11-openjdk-devel.x86_64 (java-11-openjdk-11.0.18.0.10-2.el8_7.x86_64)
 - Ant apache-ant-1.10.13
 - Signserver CE 5.11.1

This image is also prepared for HSM connection using HSM utimaco either *SecurityServer* or *CryptoServer*

## Command to create the image

docker build -t <tag_name>:<tag_version> -f Dockerbuild.ss511 .

the <tag_name>:<tag_version> examples is: local_signserver:5.11

full example : 

```sh
docker build --build-arg WILDFLY_VERSION=26.1.3.Final --build-arg WAIT_FOR_WILDFLY=10 --build-arg DISABLE_MANAGEMENT_WEB_CONSOLE=true --build-arg REMOVE_WILDFLY_WELCOME_CONTENT=true -t local_signserver:5.11.1-Final -f Dockerbuild.ss511 .

```

### build-args

build argument and also envi variables for running a container

 - WILDFLY_VERSION="26.1.3.Final"
 - WILDFLY_REPO_URL=https://github.com/wildfly/wildfly/releases/download
 - ENABLE_GLOWROOT=false
 - RUN_WILDFLY_CONFIG=false
 - DISABLE_MANAGEMENT_WEB_CONSOLE=false
 - REMOVE_WILDFLY_WELCOME_CONTENT=false
 - SIGNSERVER_VERSION=signserver-ce-5.11.1.Final
 - KEYSTORE_PASSWORD=foo123
 - TRUSTSTORE_PASSWORD=foobar
 - DB_PASSWORD=passw0rd
 - WAIT_FOR_WILDFLY=13
 - CS_PKCS11_R2_CFG (file configuration for hsm lib)
 - CS_PKCS11_R3_CFG (also file configuration for hsm lib but R3)
 - CRYPTO_SERVER_IP (IP of the HSM)

##### Problem on using `RUN_WILDFLY_CONFIG=true`

for `RUN_WILDFLY_CONFIG` if set to true and container restarted it would mess the signserver since it already deployed. It also conflicted with `REMOVE_WILDFLY_WELCOME_CONTENT` if set to `true`

### Running the container


```sh
docker run -it --name lss_2612 \
 -e WAIT_FOR_WILDFLY_TO_RUN=10 \
 -e RUN_WILDFLY_CONFIG=false \
 -e ENABLE_GLOWROOT=false \
 -e CRYPTO_SERVER_IP=172.22.0.4 \
 -e CS_PKCS11_R2_CFG=/etc/utimaco/cs_pkcs11_R2.cfg \
 -p 8888:8080 -p 8443:8443 -p 8442:8442 -p 9990:9990 \
 -p 4000:4000 \
 -v ./certificates_dir/certa_wildfly/wildfly_keystore.p12:/opt/wildfly/standalone/configuration/keystore/wildfly_keystore.p12:ro \
 -v ./certificates_dir/certa_client_wildfly/apptrustore.jks:/opt/wildfly/standalone/configuration/keystore/truststore.jks \
 -v ./transit_folder:/mnt/transit_folder \
 --network=wfNetwork \
 local_signserver:5.11.1-Final
```

### to check connectivity to HSM after container is running

Make sure the HSM and container are in the same network.
Then enter into the container then run:

```sh
cd /opt/utimaco/CryptoServerCP5-SupportingCD-V5.1.1.1/Software/Linux/x86-64/Administration/
./csadm Dev=3001@hsm_simulator GetState
```
you might wanna try other ports like 288, 3000 or 3002. Check with HSM admin

### editing HSM IP address 

you may want to edit the HSM IP Address. Do this:

Edit the hsm config file (assuming we use `/etc/utimaco/cs_pkcs11_R2.cfg`
 that is value in variable `CS_PKCS11_R2_CFG`)

`nano /etc/utimaco/cs_pkcs11_R2.cfg`

```
...
[CryptoServer]
# Device specifier (here: CryptoServer is CSLAN with IP address 192.168.0.1)
Device = 172.22.0.4
#Device = 10.3.75.25
...
```

Then reload wildfly

`/opt/wildfly/bin/jboss-cli.sh --connect ':reload'`

### Add HSM Cryptoworker P11 

create cryptoworker using admin gui and look for `WORKERGENID1.SHAREDLIBRARYNAME` 
specificati0on in conf/signserver_deploy.properties . Usualy resides in 
`/opt/signserver-custom` as per deployement

`less /opt/signserver-custom/conf/signserver_deploy.properties`

look for these kind of lines:

```sh

cryptotoken.p11.lib.254.name=Utimaco
cryptotoken.p11.lib.254.file=/opt/hsm_pkcs11.so

cryptotoken.p11.lib.255.name=UtimacoR3
cryptotoken.p11.lib.255.file=/opt/hsm_r3_pkcs11.so

```


## Signserver CLI command

some of CLI command that useful during working with signserver worker if the 
WEB GUI is not available

setup a PDF signer:

`bin/signserver setproperties $SIGNSERVER_HOME/doc/sample-configs/pdfsigner.properties`

Notice the created workerId and use it when applying the configuration 
using the reload command:

`bin/signserver reload WORKER-ID`


we can get status of all workers

`bin/signserver getstatus brief all`


remove a worker (for example worer with id 4)

```
bin/signserver removeworker 4

## after this, the worker will not be visible in the Admin Gui's workers list
## then activate the removal with the reload command
bin/signserver reload all
```




As a note, you can disable admin GUI when deploying signserver. 
edit file: `conf/signserver_deploy.properties`

find this line:

```
# Set to enable build of the AdminGUI
# Default: true
## set to false to disable AdminGUI
admingui.enabled=true

``` 
## Start, stop and restart wildfly

for starting wildfy inside container you can use:

`/run_wildfly.sh`

### stoping widlfly

`/opt/wildfly/bin/jboss-cli.sh --connect shutdown`

and then for starting it again after complete shutdown, use:

`/run_wildfly.sh`

### restarting wildfly

restarting wildfly:

`/opt/wildfly/bin/jboss-cli.sh --connect 'shutdown --restart=true'`

restarting with specify in a timeout for the shutdown

`/opt/wildfly/bin/jboss-cli.sh --connect 'shutdown --restart=true --timeout=10'`

## Troubleshoot

### Host '<ip-host>' is not allowed to connect to this MariaDB

connect to mysql

```sql
GRANT ALL ON *.* TO 'signserver'@'%';
FLUSH PRIVILEGES;
```

### org.signserver.admin.common.auth.AdminNotAuthorizedException: Administrator not authorized to resource

`/opt/signserver/bin/signserver wsadmins -allowany`

### Timeout when loading container or `.ear`

Signserver will reload all workers listed in its database. 
When the number of worker become too large, wildfly loading the signserver 
will likely to encounter timeout since the container stability will not be reached
and this error showned in log:

`WFLYCTL0348: Timeout after [300] seconds waiting for service container stability`

We can solve it by increasing the blocking timeout:

`/opt/wildfly/bin/jboss-cli.sh --connect  '/system-property=jboss.as.management.blocking.timeout:add(value=600000)'`


