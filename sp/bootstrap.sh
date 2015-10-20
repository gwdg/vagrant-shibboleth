#!/bin/sh
r=$PWD
. ./common
mkdir -p _dl
cd _dl
curl -JOLs http://shibboleth.net/downloads/embedded-discovery-service/latest/${EDS_F}
cd ..
mkdir -p _work
cd _work
tar -xzf ../_dl/${EDS_F}

