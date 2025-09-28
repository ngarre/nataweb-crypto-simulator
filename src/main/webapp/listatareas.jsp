<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.TareaDao" %>
<%@ page import="com.natalia.nataweb.model.Tarea" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.natalia.nataweb.utils.DateUtils" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>

<style>
    .table-like {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr 2fr 1fr 1fr 1fr;
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

    .edit-button {
        background-color: #007bff;
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
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("/nataweb");
        return;
    }

    isSessionActive = session.getAttribute("id") != null;
    if (!isSessionActive) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer userId = (Integer) session.getAttribute("id");
    String eliminado = request.getParameter("eliminado");
    boolean mostrarModalExito = "ok".equals(eliminado);
%>

<br>
<h2 class="mb-4">Listado de Tareas (Órdenes de Trabajo)</h2>
<br>
<br>

<div class="container d-flex justify-content-center">
    <a href="registrotarea.jsp">
        <button type="button" class="btn btn-primary btn-lg">Añadir Tarea</button>
    </a>
</div>

<br>
<br>

<%
    Database database = new Database();
    try {
        database.connect();
        TareaDao tareaDao = new TareaDao(database.getConnection());

        ArrayList<Tarea> listaTareas = tareaDao.getAll(); // Este método debe estar implementado en TareaDao
%>

<div class="container">
    <div class="table-like">
        <div class="header">Fecha Registro</div>
        <div class="header">Duración (h)</div>
        <div class="header">Coste (€)</div>
        <div class="header">Descripción</div>
        <div class="header">¿Terminada?</div>
        <div class="header">Editar</div>
        <div class="header">Eliminar</div>
    </div>

    <div class="table-like">
        <%
            for (Tarea tarea : listaTareas) {
                String resumenDescripcion = tarea.getDescripcion();
                if (resumenDescripcion.length() > 20) {
                    resumenDescripcion = resumenDescripcion.substring(0, 20) + "...";
                }
        %>
        <div class="item bold-blue"><%= DateUtils.formatDateTime2(tarea.getFechaRegistro()) %></div>
        <div class="item"><%= tarea.getDuracionHoras() %></div>
        <div class="item"><%= CurrencyUtils.format(tarea.getCosteEuros())  %></div>
        <div class="item"><%= resumenDescripcion %></div>
        <div class="item"><%= tarea.isTerminado() ? "Sí" : "No" %></div>

        <div class="item">
            <button class="edit-button" onclick="window.location.href='registrotarea.jsp?id=<%= tarea.getId() %>'">
                Editar
            </button>
        </div>

        <div class="item">
            <button class="delete-button"
                    onclick="if(confirm('¿Estás seguro de eliminar esta tarea?')) window.location.href='tareas?id=<%= tarea.getId() %>'">
                Eliminar
            </button>
        </div>
        <%
            }
        %>
    </div>
</div>

<%
} catch (Exception e) {
    e.printStackTrace();
%>
<div style="color:red">⚠️ Error al cargar las tareas.</div>
<%
    }
%>

<!-- Modal de éxito al eliminar -->
<div id="deleteSuccessModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="deleteSuccessModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title" id="deleteSuccessModalLabel">Eliminación exitosa</h5>
            </div>
            <div class="modal-body">
                <p>La tarea ha sido eliminada correctamente.</p>
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

        document.getElementById("btnCloseDeleteSuccess").addEventListener("click", function () {
            const url = new URL(window.location.href);
            url.searchParams.delete("eliminado");
            window.history.replaceState({}, document.title, url.pathname);
        });
    });
    <% } %>
</script>

<%@ include file="includes/footer.jsp" %>
