<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CriptomonedaDao" %>
<%@ page import="com.natalia.nataweb.model.Criptomoneda" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="includes/header.jsp"%>

<script>
    function validarFormulario() {
        var precio = document.getElementById("precio").value.trim();
        if (precio === "") {
            alert("El precio no puede estar vacío.");
            return false;
        }

        if (isNaN(precio) || parseFloat(precio) <= 0) {
            alert("Por favor, introduce un valor numérico válido para el Precio.");
            return false;
        }

        var nombre = document.getElementById('nombre').value;
        if (nombre.trim() === "") {
            alert("El nombre no puede estar vacío.");
            return false;
        }

        var descripcion = document.getElementById('descripcion').value;
        if (descripcion.trim() === "") {
            alert("La descripción no puede estar vacía.");
            return false;
        }

        return true;
    }
</script>

<script type="text/javascript">
    $(document).ready(function() {

        // Evento de los botones de los modales que están en el código abajo
        $('#btnAcceptSuccess').on('click', function() {
            $('#successModal').modal('hide');
            window.location.href = "gestionmonedas.jsp";
        });

        $('#btnAcceptError').on('click', function() {
            $('#errorModal').modal('hide');
        });

        $("form").on("submit", function(event) {
            event.preventDefault();
            const form = $("form")[0];
            const formData = new FormData(form);

            $.ajax({
                url: "registerMoneda",
                type: "POST",
                enctype: "multipart/form-data",
                data: formData,
                processData: false,
                contentType: false,
                cache: false,
                timeout: 10000,
                statusCode: {
                    200: function(response) {
                        if (response === "ok") {
                            $("#modalSuccessMessage").text("¡Operación correcta! Acepte para continuar");
                            $("#successModal").modal('show');
                        } else {
                            $("#modalErrorMessage").text(response);
                            $("#errorModal").modal('show');
                        }
                    },
                    500: function() {
                        $("#modalErrorMessage").text("Hubo un error en la operación");
                        $("#errorModal").modal('show');
                    }
                }
            });
        });
    });
</script>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("/nataweb");
        return;
    }

    // Recojo idParam por si se llama a la página para modificar
    String idParam = request.getParameter("id");
    int id = 0;
    String rotulo = "";
    boolean modificando = false;

    // Inicializo estas variables para que, en caso de estar modificando, puedan recuperar la información anterior
    String criptomonedaNombre = "";
    String criptomonedaDescripcion = "";
    String criptomonedaProcedencia = "";
    String criptomonedaRiesgo = "";
    String criptomonedaRentabilidad = "";
    String criptomonedaPrecio = "";
    Boolean criptomonedaHabilitada = true;

    Criptomoneda criptomoneda = null;

    if (idParam != null && !idParam.isEmpty()) {
        try {
            id = Integer.parseInt(idParam);
            rotulo = "Modificación de Criptomoneda";
            modificando = true;
        } catch (NumberFormatException e) { // Casos en los que no se pueda parsear a entero
            response.sendRedirect("/nataweb");
            return;
        }
    } else {
        rotulo = "Alta de Criptomoneda";
    }

    try {
        if (modificando) {
            Database database = new Database();
            database.connect();
            CriptomonedaDao criptomonedaDao = new CriptomonedaDao(database.getConnection());


            criptomoneda = criptomonedaDao.get(id);

//        if (criptomoneda == null) {
//            response.sendRedirect("includes/moneda_no_encontrada.jsp");
//            return;
//        }


            criptomonedaNombre = criptomoneda.getNombre();
            criptomonedaDescripcion = criptomoneda.getDescripcion();
            criptomonedaProcedencia = criptomoneda.getProcedencia();
            criptomonedaRiesgo = criptomoneda.getRiesgo();
            criptomonedaRentabilidad = criptomoneda.getRentabilidad();
            criptomonedaPrecio = String.valueOf(criptomoneda.getPrecio());
            criptomonedaHabilitada = criptomoneda.getHabilitada();
        }
%>

<h2 class="mb-4"><%= rotulo %></h2>
<br>

<div class="container d-flex justify-content-center">
    <form  style="width: 50%; padding: 20px;" onsubmit="return validarFormulario()">

        <% if (modificando) { %>
        <input type="hidden" name="id" value="<%= criptomoneda.getId() %>">
        <% } %>

        <div class="mb-3">
            <label for="imagenfoto" class="form-label">Imagen</label>
            <% if (modificando) { %>
            <input type="file" class="form-control" id="imagenfoto" name="imagenfoto">
            <small>Dejar vacío si no desea cambiar la imagen</small>
            <% } else { %>
            <input type="file" class="form-control" id="imagenfoto" name="imagenfoto" required>
            <% } %>
        </div>

        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="nombre" class="form-label">Nombre de la Criptomoneda</label>
                <input type="text" class="form-control" id="nombre" name="nombre" value="<%= criptomonedaNombre %>" required>
            </div>
            <div style="flex: 1;">
                <label for="habilitada" class="form-label">Habilitada</label>
                <select class="form-control" id="habilitada" name="habilitada" required>
                    <option value="true" <%= Boolean.TRUE.equals(criptomonedaHabilitada) ? "selected" : "" %>>Sí</option>
                    <option value="false" <%= Boolean.FALSE.equals(criptomonedaHabilitada) ? "selected" : "" %>>No</option>
                </select>
            </div>
        </div>

        <div class="mb-3">
            <label for="descripcion" class="form-label">Descripción</label>
            <textarea class="form-control" id="descripcion" name="descripcion" rows="3" required><%= criptomonedaDescripcion %></textarea>
        </div>

        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="riesgo" class="form-label">Riesgo</label>
                <select class="form-control" id="riesgo" name="riesgo" required>
                    <option value="Alto" <%= "Alto".equals(criptomonedaRiesgo) ? "selected" : "" %>>Alto</option>
                    <option value="Medio" <%= "Medio".equals(criptomonedaRiesgo) ? "selected" : "" %>>Medio</option>
                    <option value="Bajo" <%= "Bajo".equals(criptomonedaRiesgo) ? "selected" : "" %>>Bajo</option>
                </select>
            </div>
            <div style="flex: 1;">
                <label for="rentabilidad" class="form-label">Rentabilidad</label>
                <select class="form-control" id="rentabilidad" name="rentabilidad" required>
                    <option value="Alta" <%= "Alta".equals(criptomonedaRentabilidad) ? "selected" : "" %>>Alta</option>
                    <option value="Media" <%= "Media".equals(criptomonedaRentabilidad) ? "selected" : "" %>>Media</option>
                    <option value="Baja" <%= "Baja".equals(criptomonedaRentabilidad) ? "selected" : "" %>>Baja</option>
                </select>
            </div>
        </div>

        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="procedencia" class="form-label">Procedencia</label>
                <select class="form-control" id="procedencia" name="procedencia" required>
                    <option value="Americana" <%= "Americana".equals(criptomonedaProcedencia) ? "selected" : "" %>>Americana</option>
                    <option value="Asiática" <%= "Asiática".equals(criptomonedaProcedencia) ? "selected" : "" %>>Asiática</option>
                    <option value="Europea" <%= "Europea".equals(criptomonedaProcedencia) ? "selected" : "" %>>Europea</option>
                </select>
            </div>
            <div style="flex: 1;">
                <label for="precio" class="form-label">Precio de salida</label>
                <input type="text" class="form-control" id="precio" name="precio" value="<%= criptomonedaPrecio %>" required>
            </div>
        </div>

        <div class="d-flex justify-content-between">
            <button type="submit" class="btn btn-primary"><%= modificando ? "Actualizar" : "Aceptar" %></button>
            <a href="gestionmonedas.jsp" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<br><br>

<!-- Modal de éxito -->
<div id="successModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="successModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="successModalLabel">Operación Exitosa</h5>
            </div>
            <div class="modal-body">
                <p id="modalSuccessMessage">¡Operación correcta! Acepte para continuar</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="btnAcceptSuccess">Aceptar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de error -->
<div id="errorModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="errorModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="errorModalLabel">Error</h5>
            </div>
            <div class="modal-body">
                <p id="modalErrorMessage">Hubo un error en la operación. Por favor, inténtelo de nuevo.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" id="btnAcceptError">Aceptar</button>
            </div>
        </div>
    </div>
</div>


<%
    } catch (Exception e) {
    response.sendRedirect("includes/moneda_no_encontrada.jsp");
    }
%>

<%@include file="includes/footer.jsp"%>
