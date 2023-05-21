#!/bin/bash
### set JAVA_HOME environment variable

JAVA_HOME=/usr/lib/jvm/`ls /usr/lib/jvm/ | grep java-11-openjdk | grep x86_64`

export JAVA_HOME
### set PATH
PATH="$PATH:$JAVA_HOME/bin/"
export PATH

