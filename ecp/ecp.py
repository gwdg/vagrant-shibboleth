"""
This simple client uses standard Python modules
along with the Python lxml toolkit from

http://lxml.de/ 

to demonstrate how a SAML ECP client works.

Studying this client is not an acceptable replacement
for reading the ECP profile [ECP] available at

http://docs.oasis-open.org/security/saml/Post2.0/saml-ecp/v2.0/cs01/saml-ecp-v2.0-cs01.pdf

Please read the profile document and consult this script
as one example of a non-conformant client.
This script cannot be considered a conformant client as defined
in section 3.1.3 of [ECP] because it does not support the use of
channel bindings of type "tls-server-end-point" nor does it support
TLS Client Authentication.

This client has been tested on Debian Wheezy against
the Shibboleth IdP version 2.4.4 and 3.1.1 and the Shibboleth Native SP 
version 2.5.4.

The script assumes both the IdP and SP are properly configured for ECP
using basic authentication. See the Shibboleth documentation for details.
"""

import os
import sys
import stat
import urllib2
import cookielib
import re
import getpass
import base64
import ssl

from optparse import OptionParser
from lxml import etree
from copy import deepcopy

# mapping from user friendly names or tags to IdP ECP enpoints
IDP_ENDPOINTS = {
 "idp"  : "https://idp.example.org/idp/profile/SAML2/SOAP/ECP",
 "idp3" : "https://idp3.example.org/idp/profile/SAML2/SOAP/ECP",
}

class MyCookieJar(cookielib.MozillaCookieJar):
    """
    Custom cookie jar subclassed from Mozilla because the file format
    stored is not useable by the libcurl libraries. See the comment below.
    """
    def save(self, filename=None, ignore_discard=False, ignore_expires=False):
        if filename is None:
            if self.filename is not None: filename = self.filename
            else: raise ValueError(MISSING_FILENAME_TEXT)

        f = open(filename, "w")
        try:
            f.write(self.header)
            now = time.time()
            for cookie in self:
                if not ignore_discard and cookie.discard:
                    continue
                if not ignore_expires and cookie.is_expired(now):
                    continue
                if cookie.secure: secure = "TRUE"
                else: secure = "FALSE"
                if cookie.domain.startswith("."): initial_dot = "TRUE"
                else: initial_dot = "FALSE"
                if cookie.expires is not None:
                    expires = str(cookie.expires)
                else:
                    # change so that if a cookie does not have an expiration
                    # date set it is saved with a '0' in that field instead
                    # of a blank space so that the curl libraries can
                    # read in and use the cookie
                    #expires = ""
                    expires = "0"
                if cookie.value is None:
                    # cookies.txt regards 'Set-Cookie: foo' as a cookie
                    # with no name, whereas cookielib regards it as a
                    # cookie with no value.
                    name = ""
                    value = cookie.name
                else:
                    name = cookie.name
                    value = cookie.value
                f.write(
                    "\t".join([cookie.domain, initial_dot, cookie.path,
                               secure, expires, name, value])+
                    "\n")
        finally:
            f.close()

def get(idp_endpoint, sp_target, login, debug=False):
    """
    Given an IdP endpoint for ECP, the desired target
    from the SP, and a login to use against the IdP
    manage an ECP exchange with the SP and the IdP
    and print the contents of the target to stdout
    after establishing a session with the SP.
    """

    # create a cookie jar and cookie handler
    cookie_jar = cookielib.LWPCookieJar()
    cookie_handler = urllib2.HTTPCookieProcessor(cookie_jar)

    # need an instance of HTTPS handler to do HTTPS
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    httpsHandler = urllib2.HTTPSHandler(debuglevel = 0, context = ctx)
    if debug:
        httpsHandler.set_http_debuglevel(1)

    # create the base opener object
    opener = urllib2.build_opener(cookie_handler, httpsHandler)

    # headers needed to indicate to the SP an ECP request
    headers = {
                'Accept' : 'text/html; application/vnd.paos+xml',
                'PAOS'   : 'ver="urn:liberty:paos:2003-08";"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp"'
                }

    # request target from SP 
    request = urllib2.Request(url=sp_target,headers=headers)

    try:
        response = opener.open(request)
    except Exception, e:
        print >>sys.stderr, "First request to SP failed: %s" % e
        sys.exit(1)

    # convert the SP resonse from string to etree Element object
    sp_response = etree.XML(response.read())
    if debug: 
        print
        print "###### BEGIN SP RESPONSE"
        print
        print etree.tostring(sp_response)
        print
        print "###### END SP RESPONSE"
        print

    # pick out the relay state element from the SP so that it can
    # be included later in the response to the SP
    namespaces = {
        'ecp' : 'urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp',
        'S'   : 'http://schemas.xmlsoap.org/soap/envelope/',
        'paos': 'urn:liberty:paos:2003-08'
        }

    try:
        relay_state = sp_response.xpath("//ecp:RelayState", namespaces=namespaces)[0]
    except Exception, e:
        print >>sys.stderr, "Unable to parse relay state element from SP response: %s" % e
        sys.exit(1)

    if debug: 
        print
        print "###### BEGIN RELAY STATE ELEMENT"
        print
        print etree.tostring(relay_state)
        print
        print "###### END RELAY STATE ELEMENT"
        print

    # pick out the responseConsumerURL attribute so that it can
    # later be compared with the assertionConsumerURL sent by the IdP
    try:
        response_consumer_url = sp_response.xpath("/S:Envelope/S:Header/paos:Request/@responseConsumerURL", namespaces=namespaces)[0]
    except Exception, e:
        print >>sys.stderr, "Unable to parse responseConsumerURL attribute from SP response: %s" % e
        sys.exit(1)

    if debug: 
        print
        print "###### BEGIN RESPONSE CONSUMER URL"
        print
        print response_consumer_url
        print
        print "###### END RESPONSE CONSUMER URL"
        print

    # make a deep copy of the SP response and then remove the header
    # in order to create the package for the IdP
    idp_request = deepcopy(sp_response)
    header = idp_request[0]
    idp_request.remove(header)

    if debug: 
        print
        print "###### BEGIN IDP REQUEST"
        print
        print etree.tostring(idp_request)
        print
        print "###### END IDP REQUEST"
        print

    # prompt the user for a password 
    password = getpass.getpass("Enter password for login '%s': " % login)

    # POST the request to the IdP 
    request = urllib2.Request(idp_endpoint, data=etree.tostring(idp_request))
    request.get_method = lambda: 'POST'
    request.add_header('Content-Type', 'test/xml; charset=utf-8')

    # combine the login and password, base64 encode, and send 
    # using the Authorization header
    base64string = base64.encodestring('%s:%s' % (login, password)).replace('\n', '')
    request.add_header('Authorization', 'Basic %s' % base64string)

    try:
        response = opener.open(request)
    except Exception, e:
        print >>sys.stderr, "Request to IdP failed: %s" % e
        sys.exit(1)

    idp_response = etree.XML(response.read())
    if debug: 
        print
        print "###### BEGIN IDP RESPONSE"
        print
        print etree.tostring(idp_response)
        print
        print "###### END IDP RESPONSE"
        print

    try:
        assertion_consumer_service = idp_response.xpath("/S:Envelope/S:Header/ecp:Response/@AssertionConsumerServiceURL", namespaces=namespaces)[0]
    except Exception,e:
        print >>sys.stderr, "Error parsing assertionConsumerService attribute from IdP response: %s" % e
        sys.exit(1)

    if debug: 
        print
        print "###### BEGIN ASSERTION CONSUMER SERVICE URL"
        print
        print assertion_consumer_service
        print
        print "###### END ASSERTION CONSUMER SERVICE URL"
        print

    # if the assertionConsumerService attribute from the IdP 
    # does not match the responseConsumerURL from the SP
    # we cannot trust this exchange so send SOAP 1.1 fault
    # to the SP and exit
    if assertion_consumer_service != response_consumer_url:
        print >> sys.stderr, "ERROR: assertionConsumerServiceURL %s does not" % assertion_consumer_service
        print >> sys.stderr, "match responseConsumerURL %s" % response_consumer_url
        print >> sys.stderr, ""
        print >> sys.stderr, "sending SOAP fault to SP"
        
        soap_fault = """
            <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
               <S:Body>
                 <S:Fault>
                    <faultcode>S:Server</faultcode>
                    <faultstring>responseConsumerURL from SP and assertionConsumerServiceURL from IdP do not match</faultstring>
                 </S:Fault>
               </S:Body>
            </S:Envelope>
            """

        headers = {
                    'Content-Type' : 'application/vnd.paos+xml',
                    }
        
        request = urllib2.Request(url=response_consumer_url, data=soap_fault, headers=headers)
        request.get_method = lambda: 'POST'

        # POST the SOAP 1.1 fault to the SP and ignore any return 
        try:
            response = opener.open(request)
        except Exception, e:
            pass

        sys.exit(1)

    # make a deep cop of the IdP response and replace its
    # header contents with the relay state initially sent by
    # the SP
    sp_package = deepcopy(idp_response)
    sp_package[0][0] = relay_state 

    if debug: 
        print
        print "###### BEGIN PACKAGE TO SEND TO SP"
        print
        print etree.tostring(sp_package)
        print
        print "###### END PACKAGE TO SEND TO SP"
        print


    headers = {
                'Content-Type' : 'application/vnd.paos+xml',
                }

    # POST the package to the SP
    request = urllib2.Request(url=assertion_consumer_service, data=etree.tostring(sp_package), headers=headers)
    request.get_method = lambda: 'POST'

    try:
        response = opener.open(request)
    except Exception, e:
        print >>sys.stderr, "Error POSTing package to SP: %s" % e
        sys.exit(1)

    # we ignore the response from the SP here and rely on the 
    # opener() instance and the cookie jar to get the cookies
    # we need as they are sent from the SP in order to make the
    # final request

    # use existing established session to request the original target
    # from the SP
    request = urllib2.Request(url=sp_target)

    try:
        response = opener.open(request)
    except Exception, e:
        print >>sys.stderr, "Error requesting target %s from SP: %s" % (sp_target, e)
        sys.exit(1)

    # print the response from the SP to stdout
    print response.read()

    # multiple calls could be done here using the established session
    # with the SP, and the cookies could be saved to the file system
    # to be used with later processes but we do neither here and just exit

def main():
    """
    Process command line arguments and then call get() with
    the appropriate IdP endpoint.
    """

    usage = "usage: %prog [options] IdP_tag target_url login"
    parser = OptionParser(usage=usage)

    parser.add_option("-d", "--debug", 
                      action="store_true", dest="debug", default=False,
                      help="write debug output to stdout")

    (options, args) = parser.parse_args()

    if len(args) != 3:
        parser.error("incorrect number of arguments")

    idp_tag, target, login = args

    if not IDP_ENDPOINTS.has_key(idp_tag):
        parser.error("IDP tag %s is not configured" % idp_tag)

    if not re.match('^https://', target):
        parser.error("target_url is not of form https://")

    idp_endpoint = IDP_ENDPOINTS[idp_tag]
    
    # get the target from the SP using ECP exchange
    get(idp_endpoint, target, login, options.debug)

if __name__ == "__main__":
    main()

