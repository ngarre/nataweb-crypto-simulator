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

<%
    String elStamp = request.getParameter("momentoDeCorte");
    String elReferenciador = DateUtils.formatDateTime(elStamp);
    Database database = new Database();
    database.connect();

    InversionDao inversionDao = new InversionDao(database.getConnection());
    Inversion inversion = inversionDao.get(elStamp);

    // Calcular la diferencia entre el saldo final y el saldo inicial
    double diferencia = inversion.getSaldoFinal() - inversion.getSaldoInicial();
%>

<div class="container d-flex justify-content-center">
    <div class='alert alert-success text-center'>
        Referenciador
        <br>
        <%= elReferenciador  %>
    </div>
</div>
<br/>
<div class="container d-flex justify-content-center">
    <div class="mb-3">
        <h3>Detalles de tu inversion</h3>
        <br>
        <br>

        <ul class="list-group list-group-flush">
            <li class="list-group-item">Nombre del inversor: <%= inversion.getUsername() %>
            </li>
            <li class="list-group-item">Saldo de entrada: <%= CurrencyUtils.format(inversion.getSaldoInicial()) %>
            </li>
            <li class="list-group-item">Saldo resultante: <%= CurrencyUtils.format(inversion.getSaldoFinal()) %></li>
            <!-- Nueva línea para mostrar la diferencia -->
            <li class="list-group-item">Diferencia: <%= CurrencyUtils.format(diferencia) %></li>
        </ul>
    </div>
</div>
<br>
<div class="container d-flex justify-content-center">
    <a href="opiniones.jsp?momentoDeCorte=<%= elReferenciador %>&ganancia=<%= diferencia %>">
        <!-- Cambié el color del botón a verde usando 'btn-success' -->
        <button type="button" class="btn btn-success btn-lg">Dejar una opinión</button>
    </a>
</div>
<br>
<br>
<div class="container d-flex justify-content-center">
    <a href="index.jsp">
        <button type="button" class="btn btn-primary btn-lg">Continuar</button>
    </a>
</div>

<%@include file="includes/footer.jsp"%>
