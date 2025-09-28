<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CriptomonedaDao" %>
<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="com.natalia.nataweb.model.Criptomoneda" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.natalia.nataweb.model.User" %>
<%@ page import="com.natalia.nataweb.dao.UserDao" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.natalia.nataweb.utils.DateUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="includes/header.jsp"%>



<%
    // Verificar que el usuario es administrador
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("/nataweb");
        return;
    }

    // Recuperar el parámetro 'username' de la URL
    String usernameParam = request.getParameter("username");

    String username = "";
    String nombre = "";
    String apellidos = "";
    int edad = 0;
    float saldo = 0.0f;
    String ciudad = "";
    String email = "";
    Date fechaAlta = null;
    boolean cuentaActiva = true;



    User user = null;

    // Comprobar si el parámetro 'username' está presente y no está vacío
    if (usernameParam != null && !usernameParam.isEmpty()) {
        username = usernameParam;
    } else {
        // Si no se pasa el parámetro username en la URL, también redirigir
        response.sendRedirect("/nataweb");
        return;
    }

    // Obtener los datos del usuario utilizando el username
    Database database = new Database();
    database.connect();
    UserDao userDao = new UserDao(database.getConnection());
    user = userDao.get(username);

    if (user != null) {
        // Asignar los valores a las variables
        nombre = user.getNombre();
        apellidos = user.getApellidos();
        edad = user.getEdad();
        saldo = user.getSaldo();
        ciudad = user.getCiudad();
        email = user.getEmail();
        fechaAlta = user.getFechaAlta();
        cuentaActiva = user.isCuentaActiva();
    } else {
        // Si no se encuentra el usuario, redirigir
        response.sendRedirect("includes/cliente_no_encontrado.jsp");




        return;
    }
%>




<h2 class="mb-4">Mantenimiento de Clientes</h2>

<br>

<div class="container d-flex justify-content-center">

    <!-- Formulario para cambiar el estado de la cuenta -->
        <form id="statusCuentaUser" action="adminCuentaUser" method="POST">
        <!-- Campo oculto para pasar el username -->
        <input type="hidden" name="username" value="<%= username %>">
        <div class="mb-3">
            <label for="cuentaActiva" class="form-label"><strong>Estado de la cuenta</strong></label>
            <div>
                <select name="cuentaActiva" id="cuentaActiva" class="form-select">
                    <option value="true" <%= cuentaActiva ? "selected" : "" %>>Activo</option>
                    <option value="false" <%= !cuentaActiva ? "selected" : "" %>>No Activo</option>
                </select>
            </div>
        </div>
        <div>
            <button type="submit" class="btn btn-primary w-100">Actualizar Estado</button>
        </div>
    </form>
</div>

<br>

<!-- Contenido principal -->
<div class="container mt-5">
    <!-- Crear una fila de Bootstrap -->
    <div class="row justify-content-center">
        <!-- Crear una columna más estrecha (col-12 col-md-4) -->
        <div class="col-12 col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title mb-0">Información del Usuario</h5>
                </div>
                <div class="card-body">
                    <!-- Nombre de usuario -->
                    <div class="mb-1">
                        <label for="username" class="form-label mt-0 mb-0"><strong>Nombre de usuario</strong></label>
                        <p id="username" class="form-control-plaintext mt-0 mb-0 ms-3"><%= username %></p>
                    </div>

                    <!-- Nombre completo -->
                    <div class="mb-1">
                        <label for="nombre" class="form-label mt-0 mb-0"><strong>Nombre</strong></label>
                        <p id="nombre" class="form-control-plaintext mt-0 mb-0 ms-3"><%= nombre %></p>
                    </div>

                    <!-- Apellidos -->
                    <div class="mb-1">
                        <label for="apellidos" class="form-label mt-0 mb-0"><strong>Apellidos</strong></label>
                        <p id="apellidos" class="form-control-plaintext mt-0 mb-0 ms-3"><%= apellidos %></p>
                    </div>

                    <!-- Edad -->
                    <div class="mb-1">
                        <label for="edad" class="form-label mt-0 mb-0"><strong>Edad</strong></label>
                        <p id="edad" class="form-control-plaintext mt-0 mb-0 ms-3"><%= edad %></p>
                    </div>

                    <!-- Saldo -->
                    <div class="mb-1">
                        <label for="saldo" class="form-label mt-0 mb-0"><strong>Saldo</strong></label>
                        <p id="saldo" class="form-control-plaintext mt-0 mb-0 ms-3"><%= CurrencyUtils.format(saldo) %></p>
                    </div>

                    <!-- Ciudad -->
                    <div class="mb-1">
                        <label for="ciudad" class="form-label mt-0 mb-0"><strong>Ciudad</strong></label>
                        <p id="ciudad" class="form-control-plaintext mt-0 mb-0 ms-3"><%= ciudad %></p>
                    </div>

                    <!-- Email -->
                    <div class="mb-1">
                        <label for="email" class="form-label mt-0 mb-0"><strong>Email</strong></label>
                        <p id="email" class="form-control-plaintext mt-0 mb-0 ms-3"><%= email %></p>
                    </div>

                    <!-- Fecha de Alta -->
                    <div class="mb-1">
                        <label for="fechaAlta" class="form-label mt-0 mb-0"><strong>Fecha de Alta</strong></label>
                        <p id="fechaAlta" class="form-control-plaintext mt-0 mb-0 ms-3">
                            <%= DateUtils.format(fechaAlta)%>
                        </p>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>









<br>
<br>
<br>

<%@include file="includes/footer.jsp"%>
