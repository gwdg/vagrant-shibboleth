#!/bin/sh
FILE=$1
xmlstarlet ed \
  -s '//_:IDPSSODescriptor' -t elem -n 'N' \
  -i '//N' -t attr -n 'Binding'  -v 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP' \
  -i '//N' -t attr -n 'Location' -v "${ENTITY_ID}/profile/SAML2/SOAP/ECP" \
  -r '//N' -v 'SingleSignOnService' \
  $FILE

