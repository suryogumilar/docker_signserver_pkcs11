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

##### Problem on using `RUN_WILDFLY_CONFIG=true`

for `RUN_WILDFLY_CONFIG` if set to true and container restarted it would mess the signserver since it already deployed. It also conflicted with `REMOVE_WILDFLY_WELCOME_CONTENT` if set to `true`

### Running the container


```sh
docker run -it --name lss_2612 \
 -e WAIT_FOR_WILDFLY_TO_RUN=10 \
 -e RUN_WILDFLY_CONFIG=false \
 -e ENABLE_GLOWROOT=false \
 -p 8888:8080 -p 8443:8443 -p 8442:8442 -p 9990:9990 \
 -p 4000:4000 \
 -v ./certificates_dir/certa_wildfly/wildfly_keystore.p12:/opt/wildfly/standalone/configuration/keystore/wildfly_keystore.p12:ro \
 -v ./certificates_dir/certa_client_wildfly/apptrustore.jks:/opt/wildfly/standalone/configuration/keystore/truststore.jks \
 -v ./transit_folder:/mnt/transit_folder \
 --network=wfNetwork \
 local_signserver:5.11.1-Final
```
