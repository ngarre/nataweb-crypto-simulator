<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CriptomonedaDao" %>
<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="com.natalia.nataweb.model.Criptomoneda" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.natalia.nataweb.dao.UserDao" %>
<%@ page import="com.natalia.nataweb.model.User" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.natalia.nataweb.utils.DateUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="includes/header.jsp"%>

<style>
    .table-like {
        display: grid;
        grid-template-columns: 1fr 2fr 2fr 1fr 1fr 1fr 1fr;
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
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("/nataweb");
        return;
    }

    // Verificar si se debe mostrar el modal de éxito tras eliminar
    String eliminado = request.getParameter("eliminado");
    boolean mostrarModalExito = "ok".equals(eliminado);



%>

<%--BÚSQUEDA HTML POR NOMBRE Y APELLIDOS--%>
<div class="container mt-4">
    <div class="d-flex justify-content-end">
        <form action="gestionclientes.jsp" method="GET" class="d-flex align-items-center gap-3">
            <div class="d-flex align-items-center">
                <label for="criterioNombre" class="me-2" style="font-size: 0.85rem;">Nombre:</label>
                <input type="text" id="criterioNombre" name="criterioNombre" class="form-control form-control-sm"
                       style="width: 150px; font-size: 0.85rem;" value="<%= request.getParameter("criterioNombre") != null ? request.getParameter("criterioNombre") : "" %>">
            </div>

            <div class="d-flex align-items-center">
                <label for="criterioApellidos" class="me-2" style="font-size: 0.85rem;">Apellidos:</label>
                <input type="text" id="criterioApellidos" name="criterioApellidos" class="form-control form-control-sm"
                       style="width: 150px; font-size: 0.85rem;" value="<%= request.getParameter("criterioApellidos") != null ? request.getParameter("criterioApellidos") : "" %>">
            </div>

            <button type="submit" class="btn btn-sm btn-primary" style="font-size: 0.85rem;">Buscar</button>
        </form>
    </div>
</div>
<br>

<h2 class="mb-4">Gestión de Clientes</h2>
<br>
<br>



<%
    Database database = new Database();
    try {
        database.connect();
        UserDao userDao = new UserDao(database.getConnection());

        // Aquí es donde recupero, si existen, los criterios de búsqueda
        String criterioNombre = request.getParameter("criterioNombre");
        String criterioApellidos = request.getParameter("criterioApellidos");

        List<User> listaUsuarios;

        if ((criterioNombre != null && !criterioNombre.trim().isEmpty()) ||
                (criterioApellidos != null && !criterioApellidos.trim().isEmpty())) {

            listaUsuarios = userDao.buscarPorNombreYApellidos(criterioNombre, criterioApellidos);
        } else {
            listaUsuarios = userDao.getAll();
        }


        //List<User> listaUsuarios = userDao.getAll();





        // Ordenamos la lista alfabéticamente por el nombre de la criptomoneda
        Collections.sort(listaUsuarios, (u1, u2) -> u1.getNombre().compareToIgnoreCase(u2.getNombre()));

%>

<div class="container">
    <!-- Los encabezados de la tabla se colocan fuera del bucle para que solo se muestren una vez -->
    <div class="table-like">
        <div class="header">Username</div>
        <div class="header">Nombre</div>
        <div class="header">Apellidos</div>
        <div class="header">Fecha de Alta</div> <!-- Cambié "Alta" por "Fecha de Alta" -->
        <div class="header">Cuenta Activa</div>
        <div class="header">Editar</div>
        <div class="header">Eliminar</div>
    </div>

    <!-- Aquí empieza el bucle que mostrará los registros de los usuarios -->
    <div class="table-like">
        <%
            for (User user : listaUsuarios) {

        %>
        <div class="item bold-blue"><%= user.getUsername() %></div>  <!-- Mostrar Username -->

        <div class="item"><%= user.getNombre() %></div>  <!-- Mostrar Nombre -->

        <div class="item"><%= user.getApellidos() %></div>  <!-- Mostrar Apellidos -->

        <!-- Mostrar la Fecha de Alta con el formato especificado -->
<%--        <div class="item"><%= user.getFechaAlta() %></div> <!-- Mostrar Fecha de Alta -->--%>
        <div class="item"><%= DateUtils.format(user.getFechaAlta()) %></div>

        <div class="item"><%= user.isCuentaActiva() ? "Sí" : "No" %></div> <!-- Mostrar "Sí" o "No" dependiendo de si la cuenta está activa -->

        <div class="item">
            <a href="mantenimientocliente.jsp?username=<%= user.getUsername() %>" class="btn btn-warning btn-sm">Editar</a>
        </div>

        <div class="item">
            <a href="adminCuentaUser?id=<%= user.getId() %>" class="btn btn-danger btn-sm"
               onclick="return confirm('¿Estás seguro de que quieres eliminar este usuario?')">
                Eliminar
            </a>
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
                <p>El usuario ha sido eliminado correctamente.</p>
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
