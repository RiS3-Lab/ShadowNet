#!/bin/sh
mvn install:install-file \
  -Dfile=./tensorflow-lite.aar.shadownet \
  -DgroupId=org.tensorflow \
  -DartifactId=tensorflow-lite -Dversion=0.1.110 -Dpackaging=aar
