#!/bin/bash
#
# Requires bash version >= 4.
#
# This simple client uses command line tools to
# demonstrate how a SAML ECP client works.
#
# Studying this client is not an acceptable replacement
# for reading the ECP profile [ECP] available at

# http://docs.oasis-open.org/security/saml/Post2.0/saml-ecp/v2.0/cs01/saml-ecp-v2.0-cs01.pdf
#
# Please read the profile document and consult this script
# as one example of a non-conformant client.
# This script cannot be considered a conformant client as defined
# in section 3.1.3 of [ECP] because it does not support the use of
# channel bindings of type "tls-server-end-point" nor does it support
# TLS Client Authentication.
#
# This client has been tested on Debian Wheezy against
# the Shibboleth IdP versions 2.4.4 and 3.1.1
# and the Shibboleth Native SP version 2.5.4.
#
# The script assumes both the IdP and SP are properly configured for ECP
# using basic authentication. See the Shibboleth documentation for details.
#
# The script uses the command line tool 'curl' for querying the SP
# and IdP. It uses the command line tool 'xsltproc' for 
# simple parsing and manipulation of XML. Consult a reference
# on XSLT and XPath for how to craft the stylesheet inputs to
# xsltproc. A better programmer could probably make sed and grep
# do the same thing.

# hash array of tags the user can use on the command
# line that map to IdP SAML2 ECP endpoints
declare -A idp_endpoints

idp_endpoints=( 
                ["Campus01"]="https://campus01.edu/idp/profile/SAML2/SOAP/ECP" 
                ["Campus02"]="https://campus02.edu/idp/profile/SAML2/SOAP/ECP" 
                )

usage() 
{
cat << EOF
usage: `basename $0` [options] IdP_tag target_url login

OPTIONS:
    -h    Show this message
    -d    Write debug output to stdout

EXAMPLE:

`basename $0` Campus01 https://campus01.edu/my/secret/page jsmith

CONFIGURED IDP TAGS:

EOF

for tag in "${!idp_endpoints[@]}"; do echo "$tag" ; done
}

DEBUG=

while getopts "hd" OPTION
do
    case $OPTION in
        h) 
          usage
          exit 0
          ;;
        d)
          DEBUG=1
          ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -ne 3 ]
then
    usage
    exit 1
fi

# curl is required for sending to and from the SP and IdP
# xlstproc is required for gently massaging XML
# tempfile or mktemp is required for safe temporary files

type -P curl >&/dev/null || { echo "This script requires curl. Aborting." >&2; exit 1; }
type -P xsltproc >&/dev/null || { echo "This script requires xsltproc. Aborting." >&2; exit 1; }

temp_file_maker=`type -P tempfile`
if [ ! $temp_file_maker ] ; then
    temp_file_maker=`type -P mktemp`
    if [ ! $temp_file_maker ] ; then
        echo "This script requires tempfile or mktemp. Aborting." >&2
        exit 1
    fi
fi

idp_tag=$1 
target=$2
login=$3

# verify that the target is of the form https://
if [[ ! "$target" =~ ^https:// ]]
then
    echo "Target is not of the form https://..."
    exit 1
fi

# some utility functionality for deleting temporary files
declare -a on_exit_items

function on_exit()
{
    for i in "${on_exit_items[@]}"
    do
        eval $i
    done
}

function add_on_exit()
{
    local n=${#on_exit_items[*]}
    on_exit_items[$n]="$*"
    if [[ $n -eq 0 ]]; then
        trap on_exit EXIT
    fi
}

# create a file curl can use to save session cookies

cookie_file=`$temp_file_maker`
add_on_exit rm -f $cookie_file

# headers needed for ECP
header_accept="Accept:text/html; application/vnd.paos+xml"
header_paos="PAOS:ver=\"urn:liberty:paos:2003-08\";\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\""

# request the target from the SP and include headers signalling ECP
sp_resp=`curl --silent -c $cookie_file -b $cookie_file -H "$header_accept" -H "$header_paos" "$target"`

ret=$?
if [ $ret -ne 0 ]
then
    echo "First curl GET of $target failed."
    echo "Return value was $ret."
    echo "Try curl -H '$header_accept' -H '$header_paos' $target to see error."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN SP RESPONSE"
    echo
    echo $sp_resp 
    echo
    echo "###### END SP RESPONSE"
    echo
fi

# craft the request to the IdP by using xsltproc 
# and a stylesheet to remove the SOAP header
# but leave everything else

stylesheet_remove_header=`$temp_file_maker`
add_on_exit rm -f $stylesheet_remove_header

cat >> $stylesheet_remove_header <<EOF
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:S="http://schemas.xmlsoap.org/soap/envelope/" >

 <xsl:output omit-xml-declaration="yes"/>

    <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:template>

    <xsl:template match="S:Header" />

</xsl:stylesheet>
EOF

idp_request=`echo "$sp_resp" | xsltproc $stylesheet_remove_header -`  

ret=$?
if [ $ret -ne 0 ]
then
    echo "Parse error from xsltproc on first curl GET of $target."
    echo "Return value was $ret."
    echo "Use -d to see full SP response."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN IDP REQUEST"
    echo
    echo $idp_request
    echo
    echo "###### END IDP REQUEST"
    echo
fi

# pick out the relay state element from the SP response
# so that it can later be included in the package to the SP

stylesheet_get_relay_state=`$temp_file_maker`
add_on_exit rm -f $stylesheet_get_relay_state

cat >> $stylesheet_get_relay_state <<EOF
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:ecp="urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp"
 xmlns:S="http://schemas.xmlsoap.org/soap/envelope/" >

 <xsl:output omit-xml-declaration="yes"/>

 <xsl:template match="/">
     <xsl:copy-of select="//ecp:RelayState" />
 </xsl:template>

</xsl:stylesheet>
EOF

relay_state=`echo "$sp_resp" | xsltproc $stylesheet_get_relay_state -`

ret=$?
if [ $ret -ne 0 ]
then
    echo "Parse error from xsltproc for relay state element."
    echo "Return value was $ret."
    echo "Use -d to see full SP response."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN RELAY STATE ELEMENT"
    echo
    echo $relay_state
    echo
    echo "###### END RELAY STATE ELEMENT"
    echo
fi

# pick out the responseConsumerURL attribute value from the SP response
# so that it can later be compared to the assertionConsumerURL sent from
# the IdP

stylesheet_get_responseConsumerURL=`$temp_file_maker`
add_on_exit rm -f $stylesheet_get_responseConsumerURL

cat >> $stylesheet_get_responseConsumerURL <<EOF
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:ecp="urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp"
 xmlns:S="http://schemas.xmlsoap.org/soap/envelope/" 
 xmlns:paos="urn:liberty:paos:2003-08" >

 <xsl:output omit-xml-declaration="yes"/>

 <xsl:template match="/">
     <xsl:value-of select="/S:Envelope/S:Header/paos:Request/@responseConsumerURL" />
 </xsl:template>

</xsl:stylesheet>
EOF

responseConsumerURL=`echo "$sp_resp" | xsltproc $stylesheet_get_responseConsumerURL -`

ret=$?
if [ $ret -ne 0 ]
then
    echo "Parse error from xsltproc for consumer URL."
    echo "Return value was $ret."
    echo "Use -d to see full SP response."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN RESPONSE CONSUMER URL"
    echo
    echo $responseConsumerURL
    echo
    echo "###### END RESPONSE CONSUMER URL"
    echo
fi

# use curl to POST the request to the IdP the user signalled on the command line
# and use the login supplied by the user, prompting for a password
idp_endpoint=${idp_endpoints["$idp_tag"]}
idp_response=`curl --silent --fail -X POST -H 'Content-Type: text/xml; charset=utf-8' -c $cookie_file -b $cookie_file --user $login -d "$idp_request" $idp_endpoint`

ret=$?
if [ $ret -ne 0 ]
then
    echo "curl POST to IdP $idp_tag at endpoint $idp_endpoint failed."
    echo "Return value was $ret."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN IDP RESPONSE"
    echo
    echo $idp_response
    echo
    echo "###### END IDP RESPONSE"
    echo
fi

# use xlstproc to pick out the assertion consumer service URL
# from the response sent by the IdP

stylesheet_assertion_consumer_service_url=`$temp_file_maker`
add_on_exit rm -f $stylesheet_assertion_consumer_service_url

cat >> $stylesheet_assertion_consumer_service_url <<EOF
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:ecp="urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp"
 xmlns:S="http://schemas.xmlsoap.org/soap/envelope/" >

 <xsl:output omit-xml-declaration="yes"/>

 <xsl:template match="/">
     <xsl:value-of select="S:Envelope/S:Header/ecp:Response/@AssertionConsumerServiceURL" />
 </xsl:template>

</xsl:stylesheet>
EOF

assertionConsumerServiceURL=`echo "$idp_response" | xsltproc $stylesheet_assertion_consumer_service_url -`

ret=$?
if [ $ret -ne 0 ]
then
    echo "Parse error from xsltproc for ACS URL."
    echo "Return value was $ret."
    echo "Use -d to see full IDP response."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN ASSERTION CONSUMER SERVICE URL"
    echo
    echo $assertionConsumerServiceURL
    echo
    echo "###### END ASSERTION CONSUMER SERVICE URL"
    echo
fi

# compare the responseConsumerURL from the SP to the 
# assertionConsumerServiceURL from the IdP and if they
# are not identical then send a SOAP fault to the SP

if [ "$responseConsumerURL" != "$assertionConsumerServiceURL" ]
then

echo "ERROR: assertionConsumerServiceURL $assertionConsumerServiceURL does not"
echo "match responseConsumerURL $responseConsumerURL"
echo ""
echo "sending SOAP fault to SP"

read -d '' soap_fault <<"EOF"
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
     <S:Fault>
       <faultcode>S:Server</faultcode>
       <faultstring>responseConsumerURL from SP and assertionConsumerServiceURL from IdP do not match</faultstring>
     </S:Fault>
   </S:Body>
</S:Envelope>
EOF

curl --silent -X POST -c $cookie_file -b $cookie_file -d "$soap_fault" -H "Content-Type: application/vnd.paos+xml" $responseConsumerURL > /dev/null 2>&1

exit 1

fi

# craft the package to send to the SP by
# copying the response from the IdP but removing the SOAP header
# sent by the IdP and instead putting in a new header that
# includes the relay state sent by the SP

stylesheet_sp_package=`$temp_file_maker`
add_on_exit rm -f $stylesheet_sp_package

cat >> $stylesheet_sp_package <<EOF
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:soap11="http://schemas.xmlsoap.org/soap/envelope/" >

 <xsl:output omit-xml-declaration="no" encoding="UTF-8"/>

    <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:template>

    <xsl:template match="soap11:Header" >
        <soap11:Header>$relay_state</soap11:Header>
    </xsl:template>

</xsl:stylesheet>
EOF

sp_package=`echo "$idp_response" | xsltproc $stylesheet_sp_package -`

ret=$?
if [ $ret -ne 0 ]
then
    echo "Parse error from xsltproc for SP package."
    echo "Return value was $ret."
    echo "Use -d to see full IDP response."
    exit 1
fi

if [ -n "$DEBUG" ]
then
    echo
    echo "###### BEGIN PACKAGE TO SEND TO SP"
    echo
    echo $sp_package
    echo
    echo "###### END PACKAGE TO SEND TO SP"
    echo
fi

# push the response to the SP at the assertion consumer service
# URL included in the response from the IdP

curl --silent -c $cookie_file -b $cookie_file -X POST -d "$sp_package" -H "Content-Type: application/vnd.paos+xml" $assertionConsumerServiceURL > /dev/null 2>&1

ret=$?
if [ $ret -ne 0 ]
then
    echo "Second curl POST to SP failed."
    echo "Return value was $ret."
    exit 1
fi

# use curl and the existing established session to get the original target
curl --silent -c $cookie_file -b $cookie_file -X GET "$target"

# on exit the temporary files and cookies will be deleted
# a more sophisticated client could save the cookies and make
# them available for further requests from the same SP

exit 0
