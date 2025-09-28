<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.natalia.nataweb.servlet.SessionUtils" %>
<%@ page import="jakarta.servlet.http.HttpServletRequest" %>

<!doctype html>
<html lang="es" data-bs-theme="auto">
<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Invierta en Criptomonedas - NataWeb</title>

    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>



<style>
    .bg-orange {
        background-color: #ff7f00; /* Este es un color anaranjado estándar */
    }

    .admin-dropdown-menu {
        background-color: #007bff; /* azul */
    }

    /* Opcionalmente, cambiar el color del texto si lo necesitas */
    .dropdown-item {
        color: white; /* Cambiar el color del texto a blanco para que se vea mejor sobre el fondo anaranjado */
    }
</style>


</head>

<body>

<div class="container py-3">


    <header>
        <div class="d-flex flex-column flex-md-row align-items-center pb-3 mb-4 border-bottom">

                <a href="/nataweb/" class="d-flex align-items-center link-body-emphasis text-decoration-none">
                    <!-- Reemplaza el SVG con una imagen -->
                    <img src="imagenes/monedas/default_logo.jpg" alt="Nataweb" width="42" height="42" class="me-2">
                    <span class="fs-4">Invierta en criptomonedas - NataWeb</span>
                </a>


            <nav class="d-inline-flex mt-2 mt-md-0 ms-md-auto align-items-center">
                <%
                    // Llamar a la función isSessionActive() de la clase SessionUtils
                    boolean isSessionActive = SessionUtils.isSessionActive(request);
                    String userRole = (String) session.getAttribute("role");

                    if (isSessionActive) {
                        // Si el rol del usuario es admin, mostramos el menú de administración
                        if ("admin".equals(userRole)) {
                %>
                <!-- Menú desplegable para el rol de admin -->
                <div class="dropdown me-3">
                    <a class="py-2 link-body-emphasis text-decoration-none dropdown-toggle" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        Admin: <%= session.getAttribute("username") %>
                    </a>
                    <ul class="dropdown-menu admin-dropdown-menu" aria-labelledby="adminDropdown">
                        <li><a class="dropdown-item" href="/nataweb/gestionmonedas.jsp">Gestión de Monedas</a></li>
                        <li><a class="dropdown-item" href="/nataweb/gestionclientes.jsp">Gestión de Clientes</a></li>
                        <li><a class="dropdown-item" href="/nataweb/cotizaciones.jsp">Cotizaciones</a></li>
                        <li><a class="dropdown-item" href="/nataweb/listatareas.jsp">Tareas Realizadas</a></li>
                    </ul>
                </div>
                <!-- Opción de Cerrar sesión para admin -->
                <a class="py-2 link-body-emphasis text-decoration-none" href="logout">Cerrar Sesión&nbsp;&nbsp;</a>
                <%
                } else {
                %>
                <!-- Menú desplegable para el usuario normal -->
                <div class="dropdown">
                    <a class="me-3 py-2 link-body-emphasis text-decoration-none dropdown-toggle" href="#" id="dropdownMenuLink" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        Usuario: <%= session.getAttribute("username") %>
                    </a>
                    <ul class="dropdown-menu bg-orange" aria-labelledby="dropdownMenuLink">
                        <li><a class="dropdown-item" href="/nataweb/registrocliente.jsp">Modificar mi perfil</a></li>
                        <li><a class="dropdown-item" href="/nataweb/misinversiones.jsp">Mis inversiones</a></li>
                        <li><a class="dropdown-item" href="/nataweb/listaopiniones.jsp">Mis opiniones</a></li>
                    </ul>
                </div>
                <a class="me-3 py-2 link-body-emphasis text-decoration-none"> | </a>
                <a class="py-2 link-body-emphasis text-decoration-none" href="logout">Cerrar Sesión&nbsp;&nbsp;|&nbsp;&nbsp;</a>


                <a href="gestioncarrito.jsp" class="me-3 py-2 link-body-emphasis text-decoration-none">
                    Cartera&nbsp;
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-bag" viewBox="0 0 16 16">
                        <path d="M8 1a2.5 2.5 0 0 1 2.5 2.5V4h-5v-.5A2.5 2.5 0 0 1 8 1m3.5 3v-.5a3.5 3.5 0 1 0-7 0V4H1v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V4zM2 5h12v9a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1z"/>
                    </svg>
                </a>



<%--                <button type="button" class="btn btn-primary"--%>
<%--                        style="--bs-btn-padding-y: .25rem; --bs-btn-padding-x: .5rem; --bs-btn-font-size: .75rem;">--%>
<%--                    Carrito--%>
<%--                </button>--%>

                <%
                    }
                } else {
                %>
                <!-- Si la sesión no está activa, mostrar las opciones de login y registro -->
                <a class="me-3 py-2 link-body-emphasis text-decoration-none" href="/nataweb/login.jsp">Iniciar Sesión</a>
                <a class="me-3 py-2 link-body-emphasis text-decoration-none"> | </a>
                <a class="py-2 link-body-emphasis text-decoration-none" href="/nataweb/registrocliente.jsp">Regístrese</a>
                <%
                    }
                %>
            </nav>
        </div>
    </header>


    <main>




<svg xmlns="http://www.w3.org/2000/svg" class="d-none">
    <symbol id="check" viewBox="0 0 16 16">
        <title>Check</title>
        <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"/>
    </symbol>
</svg>

