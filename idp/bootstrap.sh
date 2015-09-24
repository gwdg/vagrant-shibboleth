#!/bin/sh
r=$PWD
. $r/common
mkdir -p ${STAGE_DL_D}
cd ${STAGE_DL_D}
curl -JOL $IDP_URL/$IDP_V/$IDP_F
curl -JOL $UAPPROVE_URL/$UAPPROVE_F
cd ..
mkdir -p ${STAGE_WORK_D}
cd ${STAGE_WORK_D}
tar -xzvf ${STAGE_DL_D}/$IDP_F
unzip ${STAGE_DL_D}/$UAPPROVE_F
cp -R ${UAPPROVE_D}/lib/*                                    ${IDP_D}/lib/
cp -R ${UAPPROVE_D}/lib/jdbc/*                               ${IDP_D}/lib/
cp ${UAPPROVE_D}/manual/configuration/uApprove.xml        ${IDP_D}/src/installer/resources/conf-tmpl/
cp ${UAPPROVE_D}/manual/configuration/uApprove.properties ${IDP_D}/src/installer/resources/conf-tmpl/
cp ${UAPPROVE_D}/manual/examples/terms-of-use.html        ${IDP_D}/src/installer/resources/conf-tmpl/

( cd ${IDP_D}/src/tools/bash && patch -p1 ) <$r/patches/aacli.patch

