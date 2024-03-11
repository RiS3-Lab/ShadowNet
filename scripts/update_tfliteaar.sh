#!/bin/sh
md5sum tensorflow-lite.aar.shadownet 
rm tensorflow-lite.aar.shadownet  -f 
#scp sta:~/tensorflow-lite.aar.shadownet .
cp /tmp/tensorflow-lite.aar.shadownet .
md5sum tensorflow-lite.aar.shadownet 
./mvn.sh
