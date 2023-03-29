# Signserver 5.11 docker version

using image created from [docker local build wildfly v26.1.2](https://github.com/suryogumilar/wildfly_docker/tree/wildfly_26_1_2) 

Applications used in this image are:
 - Almalinux 9.1
 - Wildfly version 26.1.2-Final   
   This is the default version, we can change it runtimely during build using 
   `--build-arg` e.g: `docker build --build-arg WILDFLY_INSTALL_VERSION=26.1.2-Final`
 - JDK java-11-openjdk-devel.x86_64 (java-11-openjdk-11.0.18.0.10-2.el8_7.x86_64)
 - Ant apache-ant-1.10.13
 - Signserver CE 5.11.1

This image is also prepared for HSM connection using HSM utimaco either *SecurityServer* or *CryptoServer*

## Command to create the image

docker build -t <tag_name>:<tag_version> -f Dockerbuild.ss511 .

the <tag_name>:<tag_version> examples is: local_signserver:5.11
