<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="java.util.List" %>
<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.model.Inversion" %>
<%@ page import="com.natalia.nataweb.dao.InversionDao" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.natalia.nataweb.utils.DateUtils" %>
<%@ page contentType="text/html;charset=UTF-8"  %>

<%@include file="includes/header.jsp"%>


<br/>
<div class="container d-flex justify-content-center">
    <div class="mb-3">
        <h3>¡ Gracias por registrar su opinión !</h3>
        <br>
        <br>
    </div>
</div>
<br>

<br>
<div class="container d-flex justify-content-center">
    <a href="index.jsp">
        <button type="button" class="btn btn-primary btn-lg">Continuar</button>
    </a>
</div>

<%@include file="includes/footer.jsp"%>
