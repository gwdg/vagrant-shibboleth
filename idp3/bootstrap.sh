#!/bin/sh
r=$PWD
cd $r
. ./config
mkdir -p _dl
cd _dl
curl -JOL $U
curl -JOL https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar
cd ..

mkdir -p _work
cd _work
tar -xzvf ../_dl/$F
cd ..

