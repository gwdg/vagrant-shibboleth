#!/usr/bin/env python
import cgi
import cgitb

print "Content-Type: text/html"     # HTML is following
print                               # blank line, end of headers

print "<html><body>foo"

print """
<!-- START: isPassive script-->
<script type="text/javascript" language="javascript">
<!--
// Written by Lukas Haemmerle <lukas.haemmerle@switch.ch>, SWITCH
/*
This isPassive script will automatically try to log in a user using the SAML2
isPassive feature.
In case a user already has an authenticated session at his Identity Provider and
given the Discovery Service can guess the user's Identity Provider, the user will
eventually be on the exact same page this script is embedded in but logged in
(= Shibboleth attributes are available and user has a valid session with the
Service Provider on the same host).
The user page also will be requested with the same GET arguments than the initial request.
 
Requirements:
- Only works if a Service Provider 2.x is installed on the same host
- JavaScript must be enabled. Otherwise the script won't have any effect.
- The script must be able to set cookies (required for Shibboleth Service Provider as well)
- In the shibboleth2.xml there must be defined a redirectErrors="#THIS PAGE#" in
  the <Errors> element. #THIS PAGE# must be the relative/absolute URL of the page
  this script is embedded in.
- It also makes sense to protect #THIS PAGE# with a lazy session in order to use
  the Shibboleth attribute that should be available after authentication.
*/
 
// Check for session cookie that contains the initial location
if(document.cookie && document.cookie.search(/_check_is_passive=/) >= 0){
    // If we have the opensaml::FatalProfileException GET arguments
    // redirect to initial location because isPassive failed
    if (
        window.location.search.search(/errorType/) >= 0
        && window.location.search.search(/RelayState/) >= 0
        && window.location.search.search(/requestURL/) >= 0
    ) {
        var startpos = (document.cookie.indexOf('_check_is_passive=')+18);
        var endpos = document.cookie.indexOf(';', startpos);
        window.location = document.cookie.substring(startpos,endpos);
    }
} else {
    // Mark browser as being isPassive checked
    document.cookie = "_check_is_passive=" + window.location;
 
    // Redirect to Shibboleth handler
    window.location = "/Shibboleth.sso/Login?isPassive=true&target=" + encodeURIComponent(window.location);
}
//-->
</script>
<!-- END: isPassive script-->
"""

cgi.print_environ()

print "</body></html>"

# cgitb.enable()
# cgi.test()

