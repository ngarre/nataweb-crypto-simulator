<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.InversionDao" %>
<%@ page import="com.natalia.nataweb.model.Inversion" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.natalia.nataweb.utils.DateUtils" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>

<style>
  .table-like {
    display: grid;
    grid-template-columns: 1.5fr 1fr 1fr 1fr 1fr 0.8fr 0.8fr;
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

  .view-button {
    background-color: #28a745;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    color: white;
    font-weight: bold;
    width: 100%;
  }

  .delete-button {
    background-color: red;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    color: white;
    font-weight: bold;
    width: 100%;
  }
</style>

<%
  isSessionActive = session.getAttribute("id") != null;
  if (!isSessionActive) {
    response.sendRedirect("login.jsp");
    return;
  }

  int userId = (Integer) session.getAttribute("id");

  String deleted = request.getParameter("deleted");
  boolean mostrarModalExito = "true".equals(deleted);
%>

<h2 class="mb-4">Mis Inversiones</h2>

<%
  Database database = new Database();
  try {
    database.connect();
    InversionDao inversionDao = new InversionDao(database.getConnection());
    List<Inversion> listaInversiones = inversionDao.getAllByUserId(userId);
    Collections.sort(listaInversiones, Comparator.comparing(Inversion::getHoraDeCierre));
%>

<div class="container">
  <div class="table-like">
    <div class="header">Hora de Cierre</div>
    <div class="header">Saldo Inicial</div>
    <div class="header">Saldo Final</div>
    <div class="header">Ganancia</div>
    <div class="header">Estado</div>
    <div class="header">Ver</div>
    <div class="header">Eliminar</div>
  </div>

  <div class="table-like">
    <%
      DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

      for (Inversion inversion : listaInversiones) {
        String horaCierreParam = inversion.getHoraDeCierre().format(formatter);
        String horaCierreFormateada = DateUtils.formatDateTime2(inversion.getHoraDeCierre());
    %>
    <div class="item bold-blue"><%= horaCierreFormateada %></div>
    <div class="item"><%= CurrencyUtils.format(inversion.getSaldoInicial()) %></div>
    <div class="item"><%= CurrencyUtils.format(inversion.getSaldoFinal()) %></div>
    <div class="item"><%= CurrencyUtils.format(inversion.getGanancia()) %></div>
    <div class="item"><%= inversion.isGananciaBool() ? "Ganancia" : "Pérdida" %></div>

    <div class="item">
      <button class="view-button"
              onclick="window.location.href='mispaquetes.jsp?idUser=<%= userId %>&horaDeCierre=<%= horaCierreParam %>'">
        Ver
      </button>
    </div>

    <div class="item">
      <button class="delete-button"
              onclick="if(confirm('¿Estás seguro de eliminar esta inversión?')) window.location.href='misInversiones?idUser=<%= userId %>&horaDeCierre=<%= horaCierreParam %>'">
        Eliminar
      </button>
    </div>
    <%
      }
    %>
  </div>
</div>

<%
} catch (ClassNotFoundException | SQLException e) {
  e.printStackTrace();
%>
<div>
  Error al conectar con la base de datos. Por favor, inténtalo de nuevo más tarde.
</div>
<%
  }
%>

<!-- Modal de éxito tras eliminar inversión -->
<div id="deleteSuccessModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="deleteSuccessModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title" id="deleteSuccessModalLabel">Eliminación exitosa</h5>
      </div>
      <div class="modal-body">
        <p>La inversión ha sido eliminada correctamente.</p>
      </div>
      <div class="modal-footer">
        <button type="button" id="btnCloseDeleteSuccess" class="btn btn-success" data-bs-dismiss="modal">Aceptar</button>
      </div>
    </div>
  </div>
</div>

<script>
  <% if (mostrarModalExito) { %>
  document.addEventListener("DOMContentLoaded", function () {
    var deleteModal = new bootstrap.Modal(document.getElementById("deleteSuccessModal"));
    deleteModal.show();

    // Eliminar parámetro 'deleted' de la URL al cerrar el modal
    document.getElementById("btnCloseDeleteSuccess").addEventListener("click", function () {
      const url = new URL(window.location.href);
      url.searchParams.delete("deleted");
      window.history.replaceState({}, document.title, url.pathname);
    });
  });
  <% } %>
</script>

<%@ include file="includes/footer.jsp" %>
