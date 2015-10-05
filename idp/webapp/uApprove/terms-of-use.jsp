<%@ include file="header.jsp" %>
<body>
    <div class="box">
        <div style="float:right;">
        </div>
        <div class="box_header">
            <img src="<%= request.getContextPath()%>/uApprove/federation-logo.png" alt="" class="federation_logo" >
            <img src="<%= request.getContextPath()%>/uApprove/logo.png" alt="" class="organization_logo">
        </div>
        <div style="float:left;">
            <h1> <fmt:message key="title"/> </h1> 
            <div id="tou-content">
                ${tou.content}
            </div>
            <div id="tou-acceptance">
                <form method="post">
                    <input type="hidden" name="relyingPartyId" value="${relyingParty.id}" />
                    <div style="float:left;">
                        <input id="accept" type="checkbox" name="accept" value="true" />
                        <label for="accept"><fmt:message key="accept"/></label>  
                    </div>
                    <div style="float:right;">
                        <input type="submit" name="confirm" value="<fmt:message key="confirm"/>" onclick="if (document.forms[0]['accept'].checked) { return true; } else { alert('<fmt:message key="rejectMessage"/>'); return false; }" />
                    </div>
                    <div style="clear:both;"></div>
                </form>
            </div>
        </div>
    </div>    
</body>
<%@ include file="footer.jsp" %>
