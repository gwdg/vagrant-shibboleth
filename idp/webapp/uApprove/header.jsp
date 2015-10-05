<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="urn:mace:shibboleth:2.0:idp:ui" prefix="idpui" %>
<%@ page import="edu.internet2.middleware.shibboleth.common.relyingparty.RelyingPartyConfigurationManager" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.authn.LoginContext" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.util.HttpServletHelper" %>
<%@ page import="java.util.Locale" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.opensaml.saml2.metadata.EntityDescriptor" %>
<%@ page import="org.opensaml.saml2.metadata.OrganizationDisplayName" %>
<%@ page import="org.opensaml.saml2.metadata.OrganizationURL" %>
<%@ page import="org.opensaml.util.storage.StorageService" %>
<%@ page import="org.opensaml.saml2.common.Extensions" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.List" %>
<%@ page import="org.opensaml.saml2.metadata.Organization" %>
<%@ page import="org.opensaml.saml2.metadata.OrganizationDisplayName" %>
<%@ page import="org.opensaml.saml2.metadata.OrganizationURL" %>
<%@ page import="org.opensaml.saml2.metadata.RoleDescriptor" %>
<%@ page import="org.opensaml.saml2.metadata.SPSSODescriptor" %>
<%@ page import="org.opensaml.samlext.saml2mdui.InformationURL" %>
<%@ page import="org.opensaml.samlext.saml2mdui.PrivacyStatementURL" %>
<%@ page import="org.opensaml.samlext.saml2mdui.UIInfo" %>
<%@ page import="org.opensaml.xml.XMLObject" %>
<%@ page import="org.owasp.esapi.ESAPI" %>
<%@ page import="org.owasp.esapi.Encoder" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%

   Encoder esapi = ESAPI.encoder();

   // get SP organization name/URL, PrivacyURL and InfoURL
   // Code taken from package edu.internet2.middleware.shibboleth.idp.ui, classes
   // ServiceTagSupport, OrganizationDisplayNameTag, OrganizationURLTag, ServicePrivacyURLTag and ServiceInformationURLTag.
   // (This data is also provided by the taglib "idpui", but the taglib doesn't support a fallback language.)

   StorageService storageService = HttpServletHelper.getStorageService(application);
   LoginContext loginContext = HttpServletHelper.getLoginContext(storageService,application, request);
   RelyingPartyConfigurationManager rpConfigMngr = HttpServletHelper.getRelyingPartyConfigurationManager(application);
   EntityDescriptor metadata = HttpServletHelper.getRelyingPartyMetadata(loginContext.getRelyingPartyId(), rpConfigMngr);

   // get browser locales
   Enumeration<Locale> locales = request.getLocales();
   List<String> languages = new ArrayList<String>();

   while (locales.hasMoreElements()) {
       Locale loc = locales.nextElement();
       languages.add(loc.getLanguage());
   }
   if (!languages.contains("en")) {
       // add "en" as fallback language
       languages.add("en");
   }

   // gather Organization and UIInfo from Metadata
   Organization metadataOrganization = null;
   UIInfo uiInfo = null;


   Extensions exts;
   OUTER1: for (RoleDescriptor role : metadata.getRoleDescriptors(SPSSODescriptor.DEFAULT_ELEMENT_NAME)) {
       // get Organization, if available
       if (role.getOrganization() != null) {
           metadataOrganization = role.getOrganization();
       }

       // get UIInfo
       exts = role.getExtensions();
       if (exts != null) {
           for (XMLObject object : exts.getOrderedChildren()) {
               if (object instanceof UIInfo) {
                   uiInfo = (UIInfo) object;
                   break OUTER1;
               }
           }
       }
   }

   // if Organization is not available in role, get it from the main entry
   if (metadataOrganization == null) {
       metadataOrganization = metadata.getOrganization();
   }


   // get organization display name
   String localizedServiceOrganizationDisplayName = null;
   if (metadataOrganization != null && metadataOrganization.getDisplayNames() != null) {
       OUTER2: for (String lang : languages) {
           for (OrganizationDisplayName name : metadataOrganization.getDisplayNames()) {
               if (name.getName() != null && name.getName().getLanguage() != null) {
                   if (name.getName().getLanguage().equals(lang)) {
                       localizedServiceOrganizationDisplayName = name.getName().getLocalString();
                       break OUTER2;
                   }
               }
           }
       }
       if (localizedServiceOrganizationDisplayName == null) {
           if (!metadataOrganization.getDisplayNames().isEmpty()) {
               OrganizationDisplayName name = metadataOrganization.getDisplayNames().get(0);
               if (name.getName() != null && name.getName().getLanguage() != null) {
                   localizedServiceOrganizationDisplayName = name.getName().getLocalString();
               }
           }
       }
   }

   // get organization URL
   String localizedServiceOrganizationURL = null;
   if (metadataOrganization != null && metadataOrganization.getURLs() != null) {
       OUTER3: for (String lang : languages) {
           for (OrganizationURL orgURL : metadataOrganization.getURLs()) {
               if (orgURL.getURL() != null && orgURL.getURL().getLanguage() != null) {
                   if (orgURL.getURL().getLanguage().equals(lang)) {
                       localizedServiceOrganizationURL = orgURL.getURL().getLocalString();
                       break OUTER3;
                   }
               }
           }
       }
       if (localizedServiceOrganizationURL == null) {
           if (!metadataOrganization.getURLs().isEmpty()) {
               OrganizationURL orgURL = metadataOrganization.getURLs().get(0);
               if (orgURL.getURL() != null && orgURL.getURL().getLanguage() != null) {
                   localizedServiceOrganizationURL = orgURL.getURL().getLocalString();
               }
           }
       }
   }
   
   // get service display name

   // get Privacy URL
   String localizedServicePrivacyStatementURL = null;
   if (uiInfo != null && uiInfo.getPrivacyStatementURLs() != null) {
       OUTER4: for (String lang : languages) {
           for (PrivacyStatementURL privacyURL : uiInfo.getPrivacyStatementURLs()) {
               if (privacyURL.getXMLLang().equals(lang)) {
                 localizedServicePrivacyStatementURL = privacyURL.getURI().getLocalString();
                 break OUTER4;
               }
           }
       }
       if (localizedServicePrivacyStatementURL == null) {
           // no matching localization available; take first found value as fallback value
           if (!uiInfo.getPrivacyStatementURLs().isEmpty()) {
               localizedServicePrivacyStatementURL = uiInfo.getPrivacyStatementURLs().get(0).getURI().getLocalString();
           }
       }
   }

   // get Information URL
   String localizedServiceInformationURL = null;
   if (uiInfo != null && uiInfo.getInformationURLs() != null) {
       OUTER5: for (String lang : languages) {
           for (InformationURL infoURL : uiInfo.getInformationURLs()) {
               if (infoURL.getXMLLang().equals(lang)) {
                 localizedServiceInformationURL = infoURL.getURI().getLocalString();
                 break OUTER5;
               }
           }
       }
       if (localizedServiceInformationURL == null) {
           // no matching localization available; take first found value as fallback value
           if (!uiInfo.getInformationURLs().isEmpty()) {
               localizedServiceInformationURL = uiInfo.getInformationURLs().get(0).getURI().getLocalString();
           }
       }
   }

   // sanitize null values
   if (localizedServicePrivacyStatementURL == null) {
       localizedServicePrivacyStatementURL = "";
   }
   if (localizedServiceInformationURL == null) {
       localizedServiceInformationURL = "";
   }
   localizedServiceOrganizationDisplayName = esapi.encodeForHTML(localizedServiceOrganizationDisplayName);
   localizedServiceOrganizationURL = esapi.encodeForHTML(localizedServiceOrganizationURL);
   localizedServicePrivacyStatementURL = esapi.encodeForHTML(localizedServicePrivacyStatementURL);
   localizedServiceInformationURL = esapi.encodeForHTML(localizedServiceInformationURL);

   // compose organization link
   String organization = "";
        
   if (localizedServiceOrganizationDisplayName != null){
       if (localizedServiceOrganizationURL != null) {
           organization += "<a href='" + localizedServiceOrganizationURL + "' target='_blank'>";
           organization += localizedServiceOrganizationDisplayName;
           organization += "</a>";
       } else {
           organization += "<strong>";
           organization += localizedServiceOrganizationDisplayName;
           organization += "</strong>";
       }
   }

%>
<!DOCTYPE html>
<html>

    <head>
        <fmt:setLocale value="${locale}"/>
        <fmt:setBundle basename="${bundle}"/>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;">
        <link rel="stylesheet" type="text/css" href="<%= request.getContextPath()%>/uApprove/styles.css"/>
        <title><fmt:message key="title"/></title>

    </head>
