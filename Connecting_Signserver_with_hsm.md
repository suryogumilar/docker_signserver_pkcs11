# Detail set on connecting signserver with Utimaco HSM

These are steps to connecting Utimaco HSM SecureServer with Signserver

### Download library from Utimaco

you can download .so library that contained in Utimaco HSM Simulator package. CryptoServerCP5 provides .so library for R2 while SecurityServer provides for R3

then extract it to a folder. e.g `/opt/utimaco`

### Make symlink for lib

make symbolic link for each .so library to ease access

```sh

ln -s /opt/utimaco/CryptoServerCP5-SupportingCD-V5.1.1.1/Software/Linux/x86-64/Crypto_APIs/PKCS11_R2/lib/libcs_pkcs11_R2.so /opt/hsm_pkcs11.so

ln -s /opt/utimaco/SecurityServerEvaluation-V4.51.0.1/Software/Linux/x86-64/Crypto_APIs/PKCS11_R3/lib/libcs_pkcs11_R3.so /opt/hsm_r3_pkcs11.so

```

### Edit cs_pkcs11_R2.cfg / cs_pkcs11_R3.cfg

Edit configuration files for the .so library. Containing parameters to connect to one or more HSMs. The content example can be found in `utimaco_conf_dir/cs_pkcs11_R2.cfg` in this repository.


```sh
nano /etc/utimaco/cs_pkcs11_R2.cfg

cp /etc/utimaco/cs_pkcs11_R2.cfg /etc/utimaco/cs_pkcs11_R3.cfg
```

edit accordingly to point at your HSM(s)

example:

```
...
[CryptoServer]
# Device specifier (here: CryptoServer is CSLAN with IP address 192.168.0.1)
Device = 172.22.0.4
#Device = 10.3.75.25
...
```

it could also be a hostname of the HSM

### edit environment variabel for HSM connection config file

place path of the HSM config file in a defined environment variable that will be read by .so library

There are two variables defined containing path to the configuration files
 - `CS_PKCS11_R2_CFG`
    This is for R2 config, read by R2 type .so library
 - `CS_PKCS11_R3_CFG`
    This is for R3 config, read by R3 type of .so library

`nano /etc/profile.d/utimaco_ss.sh`

```sh
#!/bin/bash

CS_PKCS11_R2_CFG=/etc/utimaco/cs_pkcs11_R2.cfg
export CS_PKCS11_R2_CFG

CS_PKCS11_R3_CFG=/etc/utimaco/cs_pkcs11_R3.cfg
export CS_PKCS11_R3_CFG

CRYPTO_SERVER_IP=10.1.24.6
export CRYPTO_SERVER_IP

```

### edit signserver_deploy.properties

Edit signserver_deploy.properties file to add PKCS11 Library definition  entry

```
...

## for R2
cryptotoken.p11.lib.254.name=Utimaco
cryptotoken.p11.lib.254.file=/opt/hsm_pkcs11.so

## for R3
cryptotoken.p11.lib.255.name=UtimacoR3
cryptotoken.p11.lib.255.file=/opt/hsm_r3_pkcs11.so

...

``` 

If you use Signserver v5.0 you should edit the file inside the singserver directory home. But in v5.11 you can define folder outside the signserver home with the name of `signserver-custom` containig `conf` folder and the properties file

the outside properties file path is:

`/opt/signserver-custom/conf/signserver_deploy.properties`

### redeploy signserver

enter the signserver directory then: 

`ant deploy`

