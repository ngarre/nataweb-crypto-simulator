<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.OpinionDao" %>
<%@ page import="com.natalia.nataweb.model.Opinion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>


<style>
    .bold-input {
        font-weight: bold;
    }
</style>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("user")) {
        response.sendRedirect("/nataweb");
        return;
    }

    Integer userId = (Integer) session.getAttribute("id");
    String horaDeCierre = request.getParameter("momentoDeCorte");
    String gananciaParam = request.getParameter("ganancia");
    String modoEdicion = request.getParameter("modoedicion");

    boolean editando = "true".equals(modoEdicion);

    // Variables que se mostrarán en los campos
    String descripcion = "";
    int nota = -1;
    boolean expectativa = false;
    float ganancia = 0.0f;
    String ultimoAccesoStr = "";

    if (gananciaParam != null && !gananciaParam.isEmpty()) {
        try {
            ganancia = Float.parseFloat(gananciaParam);
        } catch (NumberFormatException e) {
            ganancia = 0.0f;
        }
    }

    if (editando && horaDeCierre != null) {
        Database database = new Database();
        database.connect();
        OpinionDao opinionDao = new OpinionDao(database.getConnection());

        Opinion opinionExistente = opinionDao.getByUserIdAndHoraDeCierreString(userId, horaDeCierre);

        if (opinionExistente != null) {
            horaDeCierre = opinionExistente.getHoraDeCierreString();
            descripcion = opinionExistente.getOpinionContenido();
            nota = opinionExistente.getNota();
            expectativa = opinionExistente.isExpectativa();
            ganancia = opinionExistente.getGanancia();  // La sobrescribimos en edición


            if (opinionExistente.getUltimoAcceso() != null) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                ultimoAccesoStr = opinionExistente.getUltimoAcceso().format(formatter);
            }

        }
    }
%>

<h2 class="mb-4"><%= editando ? "Modificar Opinión" : "Registrar Opinión" %></h2>


<% if (editando) { %>
<p><strong>Último Acceso:</strong> <%= ultimoAccesoStr %></p>
<% } %>

<div class="container d-flex justify-content-center">
    <form action="misOpiniones" method="POST" style="width: 50%; padding: 20px;" onsubmit="return validateForm()">

        <!-- Campos ocultos -->
        <input type="hidden" name="userId" value="<%= userId %>" />
        <input type="hidden" name="horadecierre" value="<%= horaDeCierre %>" />
        <input type="hidden" name="modoEdicion" value="<%= editando %>" />

        <!-- Campo de Hora de Cierre y Ganancia -->
        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label class="form-label">Hora de Cierre</label>
                <div class="fw-bold pt-1" style="border: 1px solid #ced4da; border-radius: 0.375rem; padding: .375rem .75rem; background-color: #e9ecef;">
                    <%= horaDeCierre != null ? horaDeCierre : "" %>
                </div>
            </div>

            <div style="flex: 1;">
                <label class="form-label">Ganancia</label>
                <div class="fw-bold pt-1" style="border: 1px solid #ced4da; border-radius: 0.375rem; padding: .375rem .75rem; background-color: #e9ecef;">
                    <%= CurrencyUtils.format(ganancia) %>
                </div>
                <input type="hidden" name="ganancia" value="<%= ganancia %>" />
            </div>
        </div>

        <!-- Campo de Descripción -->
        <div class="mb-3">
            <label for="descripcion" class="form-label">Deja tu opinión</label>
            <textarea class="form-control" id="descripcion" name="descripcion" rows="3" required><%= descripcion %></textarea>
            <div id="descripcionError" style="color: red; display: none;">La descripción no debe ser nula ni exceder los 180 caracteres.</div>
        </div>

        <!-- Campo Expectativa y Nota -->
        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="expectativa" class="form-label">¿Era lo esperado?</label>
                <select class="form-control" id="expectativa" name="expectativa" >
                    <option value="" <%= !editando ? "selected" : "" %>>Selecciona una opción</option>
                    <option value="true" <%= (expectativa && editando) ? "selected" : "" %>>Sí</option>
                    <option value="false" <%= (!expectativa && editando) ? "selected" : "" %>>No</option>
                </select>
                <div id="expectativaError" style="color: red; display: none;">Por favor selecciona una opción.</div>
            </div>

            <div style="flex: 1;">
                <label for="nota" class="form-label">¿Qué nota pondrías?</label>
                <select class="form-control" id="nota" name="nota" >
                    <option value="">Selecciona una opción</option>
                    <% for (int i = 0; i <= 10; i++) { %>
                    <option value="<%= i %>" <%= i == nota ? "selected" : "" %>><%= i %></option>
                    <% } %>
                </select>
                <div id="notaError" style="color: red; display: none;">Por favor selecciona una nota entre 0 y 10.</div>
            </div>
        </div>

        <!-- Botones -->
        <div class="d-flex justify-content-between">
            <button type="submit" class="btn btn-primary"><%= editando ? "Actualizar" : "Aceptar" %></button>
            <a href="/nataweb" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<%@ include file="includes/footer.jsp" %>

<script>
    function validateForm() {
        let isValid = true;

        const descripcion = document.getElementById("descripcion").value;
        const descripcionError = document.getElementById("descripcionError");
        if (descripcion.trim() === "" || descripcion.length > 180) {
            descripcionError.style.display = "block";
            isValid = false;
        } else {
            descripcionError.style.display = "none";
        }

        const expectativa = document.getElementById("expectativa").value;
        const expectativaError = document.getElementById("expectativaError");
        if (expectativa === "") {
            expectativaError.style.display = "block";
            isValid = false;
        } else {
            expectativaError.style.display = "none";
        }

        const nota = document.getElementById("nota").value;
        const notaError = document.getElementById("notaError");
        if (nota === "" || isNaN(nota) || nota < 0 || nota > 10) {
            notaError.style.display = "block";
            isValid = false;
        } else {
            notaError.style.display = "none";
        }

        return isValid;
    }
</script>
