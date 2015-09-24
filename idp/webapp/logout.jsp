<%@page import="edu.internet2.middleware.shibboleth.idp.session.Session" %>
<%@page import="edu.internet2.middleware.shibboleth.idp.session.ServiceInformation" %>
<%@page import="edu.internet2.middleware.shibboleth.idp.profile.saml2.SLOProfileHandler" %>
<%@page import="org.owasp.esapi.Encoder" %>
<%@page import="org.owasp.esapi.ESAPI" %>
<html>
  <head>
    <title>Example Logout Page</title>
  </head>

  <body>
	<img src="<%= request.getContextPath()%>/images/dummylogo.png" alt="Replace or remove this logo"/>
    <h1>Example Logout Page</h1>
    <p>This logout page is an example and should be customized.</p>

    <p>This page is displayed when a logout operation at the Identity Provider completes.</p>
    
    <p><strong>It does NOT result in the user being logged out of any of the applications he/she
    has accessed during a session, with the possible exception of a Service Provider that may have
    initiated the logout operation.</strong></p>

    <p>If your Identity Provider deployment relies on the built-in Session mechanism for SSO, the
    following is a list of Service Provider identifiers tracked by the session that has been terminated:</p>
    
    <%
    Session s = (Session) request.getAttribute(SLOProfileHandler.HTTP_LOGOUT_BINDING_ATTRIBUTE);
    if (s != null && !s.getServicesInformation().isEmpty()) {
    	Encoder esapi = ESAPI.encoder();
    %>

		<ul>
		<% for (ServiceInformation info : s.getServicesInformation().values()) { %>
			<li><%= esapi.encodeForHTML(info.getEntityID()) %></li>
		<% } %>
		</ul>	

	<% } else { %>
	
		<p>NONE FOUND</p>
	
	<% } %>

  </body>
</html>