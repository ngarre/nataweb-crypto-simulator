<%@include file="includes/header.jsp"%>


<%
        String aviso =request.getParameter("errorMessage");

%>
<h1><%= aviso %></h1>


<br>
<br>


<%@include file="includes/footer.jsp"%>