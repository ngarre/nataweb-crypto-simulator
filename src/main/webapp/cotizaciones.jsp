<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CotizacionDao" %>
<%@ page import="com.natalia.nataweb.model.Cotizacion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="com.natalia.nataweb.utils.DateUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>

<style>
    .table-like {
        display: grid;
        grid-template-columns: 1fr 1.2fr 1fr 0.8fr 1fr 1fr 1fr;
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
    }

    .bold-blue {
        font-weight: bold;
        color: blue;
    }

    .pagination {
        justify-content: center;
        margin-top: 30px;
    }

    .valor-alza-subio {
        color: #007bff;
        font-weight: bold;
        text-align: left;
    }

    .valor-alza-bajo {
        color: #ff6600;
        font-weight: bold;
        text-align: left;
    }

    .table-like .item.tendencia {
        text-align: left;
    }
</style>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("/nataweb");
        return;
    }
%>

<%
    Database database = new Database();
    try {
        database.connect();
        CotizacionDao cotizacionDao = new CotizacionDao(database.getConnection());
        ArrayList<Cotizacion> cotizacionesList = cotizacionDao.getAllCotizaciones();

        String orden = request.getParameter("orden");
        boolean ordenInverso = "inverso".equals(orden);

        // Esto es lo que hará el botón cuando se pulse: establece la acción y pone el nombre del botón
        String nuevoOrden = ordenInverso ? "normal" : "inverso";
        String textoOrden = ordenInverso ? "Ordenar por más antiguos" : "Ordenar por más recientes";

        // Ordenar la lista según parámetro
        if (ordenInverso) {
            cotizacionesList.sort((c1, c2) -> c2.getHoraDeCorte().compareTo(c1.getHoraDeCorte()));
        } else {
            cotizacionesList.sort((c1, c2) -> c1.getHoraDeCorte().compareTo(c2.getHoraDeCorte()));
        }

        int totalRegistros = cotizacionesList.size();
        int registrosPorPagina = 10;
        int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);

        String paginaStr = request.getParameter("pagina");
        int paginaActual = 1;
        if (paginaStr != null) {
            try {
                paginaActual = Integer.parseInt(paginaStr);
                if (paginaActual < 1) paginaActual = 1;
                if (paginaActual > totalPaginas) paginaActual = totalPaginas;
            } catch (NumberFormatException e) {
                paginaActual = 1;
            }
        }

        int inicio = (paginaActual - 1) * registrosPorPagina;
        int fin = Math.min(inicio + registrosPorPagina, totalRegistros);
%>

<div class="container mt-4">
    <div class="d-flex justify-content-between">
        <a href="cotizaciones.jsp?orden=<%= nuevoOrden %>"
           class="btn btn-sm btn-success"
           style="font-size: 0.85rem;">
            <%= textoOrden %>
        </a>

        <a href="actualizaCotizacion?accion=borrar"
           class="btn btn-sm btn-primary"
           style="font-size: 0.85rem;"
           onclick="return confirm('¿Seguro que quieres borrar todas las cotizaciones?')">
            Borrar todas las cotizaciones
        </a>
    </div>
</div>

<br>

<div class="container">
    <h2 class="mb-4">Listado de Cotizaciones</h2>

    <!-- Cabecera -->
    <div class="table-like">
        <div class="header">Criptomoneda</div>
        <div class="header">Hora de Corte</div>
        <div class="header">Precio</div>
        <div class="header">Variación</div>
        <div class="header">Precio Anterior</div>
        <div class="header">Actualizado por</div>
        <div class="header">Tendencia</div>
    </div>

    <!-- Filas dinámicas -->
    <div class="table-like">
        <%
            for (int i = inicio; i < fin; i++) {
                Cotizacion cotizacion = cotizacionesList.get(i);
        %>
        <div class="item"><%= cotizacion.getNombreCripto() %></div>
        <div class="item"><%= DateUtils.formatDateTime2(cotizacion.getHoraDeCorte()) %></div>
        <div class="item"><%= CurrencyUtils.format(cotizacion.getPrecio()) %></div>
        <div class="item"><%= cotizacion.getPorcentajeVariacion() %>%</div>
        <div class="item"><%= CurrencyUtils.format(cotizacion.getPrecioAnterior()) %></div>
        <div class="item"><%= cotizacion.getRecalculadoPor() != null ? cotizacion.getRecalculadoPor() : "-" %></div>
        <div class="item tendencia">
            <%
                if (cotizacion.isValorAlza()) {
            %>
            <span class="valor-alza-subio">🔼 Subió</span>
            <%
            } else {
            %>
            <span class="valor-alza-bajo">🔽 Bajó</span>
            <%
                }
            %>
        </div>
        <%
            }
        %>
    </div>

    <!-- Paginación -->
    <nav>
        <ul class="pagination">
            <li class="page-item <%= (paginaActual == 1) ? "disabled" : "" %>">
                <a class="page-link" href="cotizaciones.jsp?pagina=<%= paginaActual - 1 %>&orden=<%= orden != null ? orden : "normal" %>">Anterior</a>
            </li>
            <li class="page-item disabled">
                <a class="page-link" href="#">Página <%= paginaActual %> de <%= totalPaginas %></a>
            </li>
            <li class="page-item <%= (paginaActual == totalPaginas) ? "disabled" : "" %>">
                <a class="page-link" href="cotizaciones.jsp?pagina=<%= paginaActual + 1 %>&orden=<%= orden != null ? orden : "normal" %>">Siguiente</a>
            </li>
        </ul>
    </nav>
</div>

<%
} catch (Exception e) {
    e.printStackTrace();
%>
<div style="color:red">⚠️ Error al cargar las cotizaciones.</div>
<%
    }
%>

<%@ include file="includes/footer.jsp" %>
