<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.PaqueteDao" %>
<%@ page import="com.natalia.nataweb.model.Paquete" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>

<style>
  .table-like {
    display: grid;
    grid-template-columns: 1.2fr 1fr 1fr 1fr 1fr 1fr 1fr;
    gap: 15px;
    text-align: center;
    margin-top: 20px;
  }
  .table-like .header {
    font-weight: bold;
    background-color: #f8f9fa;
    padding: 10px;
  }
  .table-like .item {
    padding: 10px;
    border-bottom: 1px solid #ddd;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .bold-blue {
    font-weight: bold;
    color: blue;
  }
</style>

<%
  // Verificar que el usuario es un usuario/cliente
  String role = (String) session.getAttribute("role");
  if (role == null || !role.equals("user")) {
    response.sendRedirect("/nataweb");
    return;
  }
%>

<%
  // Obtener los parámetros desde la URL
  String idUserParam = request.getParameter("idUser");
  String horaDeCierreParam = request.getParameter("horaDeCierre");

  if (idUserParam == null || horaDeCierreParam == null) {
%>
<div class="alert alert-danger">Faltan parámetros: idUser y horaDeCierre son requeridos.</div>
<%
} else {
  int idUser = Integer.parseInt(idUserParam);
  LocalDateTime horaDeCierre = LocalDateTime.parse(horaDeCierreParam, DateTimeFormatter.ISO_LOCAL_DATE_TIME);

  Database database = new Database();
  try {
    database.connect();
    PaqueteDao paqueteDao = new PaqueteDao(database.getConnection());

    // Obtener la lista de paquetes para ese usuario y hora
    List<Paquete> listaPaquetes = paqueteDao.getAllByUserIdAndHora(idUser, horaDeCierre);

    // Ordenar por nombre de moneda
    Collections.sort(listaPaquetes, Comparator.comparing(Paquete::getNombreMoneda));
%>

<h2 class="mb-4">Mis Paquetes</h2>
<br><br>

<div class="container">
  <div class="table-like">
    <div class="header">Moneda</div>
    <div class="header">Cantidad</div>
    <div class="header">Precio Compra</div>
    <div class="header">Total Compra</div>
    <div class="header">Precio Venta</div>
    <div class="header">Total Venta</div>
    <div class="header">Ganancia</div>
  </div>

  <div class="table-like">
    <%
      for (Paquete paquete : listaPaquetes) {
    %>
    <div class="item bold-blue"><%= paquete.getNombreMoneda() %></div>
    <div class="item"><%= paquete.getCantidadComprada() %></div>
    <div class="item"><%= CurrencyUtils.format(paquete.getPrecioCompra()) %></div>
    <div class="item"><%= CurrencyUtils.format(paquete.getTotalCompra()) %></div>
    <div class="item"><%= CurrencyUtils.format(paquete.getPrecioVenta()) %></div>
    <div class="item"><%= CurrencyUtils.format(paquete.getTotalVenta()) %></div>
    <div class="item"><%= CurrencyUtils.format(paquete.getGanancia()) %></div>
    <%
      }
    %>
  </div>

</div>

<br>
<br>
<div class="container d-flex justify-content-center">
  <button type="button" class="btn btn-primary btn-lg" onclick="window.history.back();">
    Volver
  </button>
</div>


<%
} catch (ClassNotFoundException | SQLException e) {
  e.printStackTrace();
%>
<div>Error al conectar con la base de datos. Intenta nuevamente más tarde.</div>
<%
    }
  }
%>

<br><br><br>
<%@ include file="includes/footer.jsp" %>
