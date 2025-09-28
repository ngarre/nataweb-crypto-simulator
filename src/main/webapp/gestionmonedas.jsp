<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CriptomonedaDao" %>
<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="com.natalia.nataweb.model.Criptomoneda" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="includes/header.jsp"%>

<style>
    .table-like {
        display: grid;
        grid-template-columns: 1fr 2fr 1fr 1fr 1fr 1fr; /* Añadido espacio para la columna "Habilitada" */
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
    .table-like .item img {
        width: 45px;  /* Tamaño fijo de la imagen */
        height: 45px; /* Tamaño fijo de la imagen */
        object-fit: contain; /* Mantiene la relación de aspecto de la imagen */
    }
</style>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("/nataweb");
        return;
    }

    // Verificar si se debe mostrar el modal de éxito tras eliminar
    String eliminado = request.getParameter("eliminado");
    boolean mostrarModalExito = "ok".equals(eliminado);

%>

<%--HTML de las búsquedas por precio min, max y por habilitada --%>
<div class="container mt-4">
    <div class="d-flex justify-content-end">
        <form action="gestionmonedas.jsp" method="GET" class="d-flex align-items-center gap-3">
            <div class="d-flex align-items-center">
                <label for="minPrecio" class="me-2" style="font-size: 0.85rem;">Precio mínimo:</label>
                <input type="text" id="minPrecio" name="minPrecio" class="form-control form-control-sm"
                       style="width: 120px; font-size: 0.85rem;"
                       value="<%= request.getParameter("minPrecio") != null ? request.getParameter("minPrecio") : "" %>">
            </div>

            <div class="d-flex align-items-center">
                <label for="maxPrecio" class="me-2" style="font-size: 0.85rem;">Precio máximo:</label>
                <input type="text" id="maxPrecio" name="maxPrecio" class="form-control form-control-sm"
                       style="width: 120px; font-size: 0.85rem;"
                       value="<%= request.getParameter("maxPrecio") != null ? request.getParameter("maxPrecio") : "" %>">
            </div>

            <div class="d-flex align-items-center">
                <label for="criterioEstado" class="me-2" style="font-size: 0.85rem;">Habilitada:</label>
                <select id="criterioEstado" name="criterioEstado" class="form-select form-select-sm"
                        style="width: 120px; font-size: 0.85rem;">
                    <option value="">-- Estado --</option>
                    <option value="Sí" <%= "Sí".equals(request.getParameter("criterioEstado")) ? "selected" : "" %>>Sí</option>
                    <option value="No" <%= "No".equals(request.getParameter("criterioEstado")) ? "selected" : "" %>>No</option>
                </select>
            </div>

            <button type="submit" class="btn btn-sm btn-primary" style="font-size: 0.85rem;">Buscar</button>
        </form>
    </div>
</div>
<br>



<h2 class="mb-4">Gestión de Monedas</h2>
<br>
<br>

<div class="container d-flex justify-content-center">
    <a href="registromoneda.jsp">
        <button type="button" class="btn btn-primary btn-lg">Añadir Criptomoneda</button>
    </a>
</div>

<br>
<br>

<%
    Database database = new Database();
    try {
        database.connect();
        CriptomonedaDao cmonedaDao = new CriptomonedaDao(database.getConnection());

        String criterioEstado = request.getParameter("criterioEstado");
        String minStr = request.getParameter("minPrecio");
        String maxStr = request.getParameter("maxPrecio");

        // Cuando no hago búsqueda, asigno yo los valores para recuperar todas las monedas
        // Es decir, aquí no uso ningún método getAll para recuperar todas las monedas
        double minPrecio = 0;
        double maxPrecio = Double.MAX_VALUE; // Esto vale prácticamente INFINITO

        if (minStr != null && !minStr.trim().isEmpty()) {
            try {
                minPrecio = Double.parseDouble(minStr.trim());
            } catch (NumberFormatException e) {
                minPrecio = 0; // valor por defecto
            }
        }

        if (maxStr != null && !maxStr.trim().isEmpty()) {
            try {
                maxPrecio = Double.parseDouble(maxStr.trim());
            } catch (NumberFormatException e) {
                maxPrecio = Double.MAX_VALUE; // sin límite
            }
        }

        List<Criptomoneda> listaCriptomonedas = cmonedaDao.buscarPorPrecioYEstado(minPrecio, maxPrecio, criterioEstado);

        listaCriptomonedas.sort((c1, c2) -> c1.getNombre().compareToIgnoreCase(c2.getNombre()));
%>

<div class="container">
    <!-- Los encabezados de la tabla se colocan fuera del bucle para que solo se muestren una vez -->
    <div class="table-like">
        <div class="header">Moneda</div>
        <div class="header">Nombre</div>
        <div class="header">Precio</div>
        <div class="header">Habilitada</div> <!-- Nueva columna Habilitada -->
        <div class="header">Editar</div>
        <div class="header">Eliminar</div>
    </div>

    <!-- Aquí empieza el bucle que mostrará los registros de criptomonedas -->
    <div class="table-like">
        <%
            for (Criptomoneda cmoneda : listaCriptomonedas) {
        %>
        <div class="item">
            <img src="<%= request.getContextPath() %>/ControlerIMG?id=<%= cmoneda.getId() %>" alt="<%= cmoneda.getNombre() %>">
        </div>

        <div class="item"><%= cmoneda.getNombre() %></div>
        <div class="item"><%= CurrencyUtils.format(cmoneda.getPrecio()) %></div>

        <!-- Nueva columna "Habilitada" -->
        <div class="item"><%= cmoneda.getHabilitada() ? "Sí" : "No" %></div> <!-- Mostrar "Sí" o "No" dependiendo de Habilitada -->

        <div class="item">
            <a href="registromoneda.jsp?id=<%= cmoneda.getId() %>" class="btn btn-warning btn-sm">Editar</a>
        </div>
        <div class="item">
            <a href="registerMoneda?id=<%= cmoneda.getId() %>" class="btn btn-danger btn-sm"
               onclick="return confirm('¿Estás seguro de que quieres eliminar esta criptomoneda?')">Eliminar</a>
        </div>
        <%
            }
        %>
    </div>
</div>

<%
} catch (ClassNotFoundException cnfe) {
    cnfe.printStackTrace();
%>
<div>
    Error al conectar con la base de datos. Fallo con el driver.
</div>

<%
} catch (SQLException sqle) {
    sqle.printStackTrace();
%>
<div>
    Error al conectar con la base de datos. Comprueba que está iniciada y la configuración es correcta.
</div>
<%
    }
%>

<br>
<br>
<br>


<!-- Modal de éxito al eliminar -->
<div id="deleteSuccessModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="deleteSuccessModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title" id="deleteSuccessModalLabel">Eliminación exitosa</h5>
            </div>
            <div class="modal-body">
                <p>La criptomoneda ha sido eliminada correctamente.</p>
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

        // Limpiar el parámetro 'eliminado' de la URL después de mostrar el modal
        document.getElementById("btnCloseDeleteSuccess").addEventListener("click", function () {
            const url = new URL(window.location.href);
            url.searchParams.delete("eliminado");
            // la siguiente línea es para que se el usuario refresca pantalla que no le
            // vuelva a saltar el modal.
            window.history.replaceState({}, document.title, url.pathname);
        });
    });
    <% } %>
</script>





<%@include file="includes/footer.jsp"%>
