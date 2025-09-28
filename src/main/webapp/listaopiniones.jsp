<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.OpinionDao" %>
<%@ page import="com.natalia.nataweb.model.Opinion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>

<style>
    .table-like {
        display: grid;
        grid-template-columns: 1.5fr 3fr 1fr 1fr 1fr 0.8fr 0.8fr;
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
    if (role == null || !role.equals("user")) {
        response.sendRedirect("/nataweb");
        return;
    }

    isSessionActive = session.getAttribute("id") != null;
    if (!isSessionActive) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer userId = (Integer) session.getAttribute("id");

    // Verificar si se debe mostrar el modal de éxito tras eliminar
    String eliminado = request.getParameter("eliminado");
    boolean mostrarModalExito = "ok".equals(eliminado);
%>

<div class="container mt-4">
    <div class="d-flex justify-content-end">
        <form action="listaopiniones.jsp" method="GET" class="d-flex align-items-center gap-3">
            <div class="d-flex align-items-center">
                <label for="notaDesde" class="me-2" style="font-size: 0.85rem;">Nota desde:</label>
                <input type="number" min="0" max="10" id="notaDesde" name="notaDesde"
                       class="form-control form-control-sm" style="width: 100px; font-size: 0.85rem;"
                       value="<%= request.getParameter("notaDesde") != null ? request.getParameter("notaDesde") : "" %>">
            </div>

            <div class="d-flex align-items-center">
                <label for="notaHasta" class="me-2" style="font-size: 0.85rem;">Nota hasta:</label>
                <input type="number" min="0" max="10" id="notaHasta" name="notaHasta"
                       class="form-control form-control-sm" style="width: 100px; font-size: 0.85rem;"
                       value="<%= request.getParameter("notaHasta") != null ? request.getParameter("notaHasta") : "" %>">
            </div>

            <div class="d-flex align-items-center">
                <label for="expectativa" class="me-2" style="font-size: 0.85rem;">Expectativa:</label>
                <select id="expectativa" name="expectativa" class="form-select form-select-sm"
                        style="width: 150px; font-size: 0.85rem;">
                    <option value="">Todas</option>
                    <option value="1" <%= "1".equals(request.getParameter("expectativa")) ? "selected" : "" %>>Positiva</option>
                    <option value="0" <%= "0".equals(request.getParameter("expectativa")) ? "selected" : "" %>>Negativa</option>
                </select>
            </div>

            <button type="submit" class="btn btn-sm btn-primary" style="font-size: 0.85rem;">Buscar</button>
        </form>
    </div>
</div>

<br>

<h2 class="mb-4">Mis Opiniones</h2>
<br>

<%
    Database database = new Database();
    try {
        database.connect();
        OpinionDao opinionDao = new OpinionDao(database.getConnection());

        //ArrayList<Opinion> listaOpiniones = opinionDao.getAllByUserId(userId);

        String notaDesdeStr = request.getParameter("notaDesde");
        String notaHastaStr = request.getParameter("notaHasta");
        String expectativaStr = request.getParameter("expectativa");

        Integer notaDesde = (notaDesdeStr != null && !notaDesdeStr.isEmpty()) ? Integer.parseInt(notaDesdeStr) : null;
        Integer notaHasta = (notaHastaStr != null && !notaHastaStr.isEmpty()) ? Integer.parseInt(notaHastaStr) : null;
        Boolean expectativa = (expectativaStr != null && !expectativaStr.isEmpty()) ? "1".equals(expectativaStr) : null;

        ArrayList<Opinion> listaOpiniones;

        if (notaDesde != null || notaHasta != null || expectativa != null) {
            listaOpiniones = opinionDao.buscarPorFiltros(userId, notaDesde, notaHasta, expectativa);
        } else {
            listaOpiniones = opinionDao.getAllByUserId(userId);
        }








%>

<div class="container">
    <div class="table-like">
        <div class="header">Hora de Cierre</div>
        <div class="header">Opinión</div>
        <div class="header">Nota</div>
        <div class="header">Ganancia</div>
        <div class="header">Expectativa</div>
        <div class="header">Editar</div>
        <div class="header">Eliminar</div>
    </div>

    <div class="table-like">
        <%
            for (Opinion op : listaOpiniones) {
                String resumenOpinion = op.getOpinionContenido();
                if (resumenOpinion.length() > 30) {
                    resumenOpinion = resumenOpinion.substring(0, 30) + "...";
                }
        %>
        <div class="item bold-blue"><%= op.getHoraDeCierreString() %></div>
        <div class="item"><%= resumenOpinion %></div>
        <div class="item"><%= op.getNota() %></div>
        <div class="item"><%= op.getGanancia() %> €</div>
        <div class="item"><%= op.isExpectativa() ? "Positiva" : "Negativa" %></div>

        <div class="item">
            <button class="edit-button" onclick="window.location.href='opiniones.jsp?momentoDeCorte=<%= op.getHoraDeCierreString() %>&modoedicion=true'">
                Editar
            </button>
        </div>

        <div class="item">
            <button class="delete-button"
                    onclick="if(confirm('¿Estás seguro de eliminar esta opinión?')) window.location.href='misOpiniones?userId=<%= userId %>&horaDeCierreString=<%= op.getHoraDeCierreString() %>&action=delete'">
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
<div style="color:red">⚠️ Error al cargar opiniones.</div>
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
                <p>La opinión ha sido eliminada correctamente.</p>
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

<%@ include file="includes/footer.jsp" %>
