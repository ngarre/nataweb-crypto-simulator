<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.TareaDao" %>
<%@ page import="com.natalia.nataweb.model.Tarea" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp" %>

<script>
  function validarFormulario() {
    const duracion = document.getElementById("duracionHoras").value.trim();
    const coste = document.getElementById("costeEuros").value.trim();
    const descripcion = document.getElementById("descripcion").value.trim();

    if (duracion === "" || isNaN(duracion) || parseInt(duracion) <= 0) {
      alert("Introduce una duración válida (entero mayor que 0).");
      return false;
    }

    if (coste === "" || isNaN(coste) || parseFloat(coste) < 0) {
      alert("Introduce un coste válido (número positivo o 0).");
      return false;
    }

    if (descripcion === "") {
      alert("La descripción no puede estar vacía.");
      return false;
    }

    return true;
  }
</script>

<%
  String role = (String) session.getAttribute("role");
  if (role == null || !role.equals("admin")) {
    response.sendRedirect("/nataweb");
    return;
  }

  String idParam = request.getParameter("id");
  int id = 0;
  boolean modificando = false;
  String rotulo = "Alta de Tarea";

  int duracionHoras = 1;
  float costeEuros = 0.0f;
  String descripcion = "";
  boolean terminado = false;

  Tarea tarea = null;

  if (idParam != null && !idParam.isEmpty()) {
    try {
      id = Integer.parseInt(idParam);
      if (id > 0) {
        modificando = true;
        rotulo = "Modificación de Tarea";

        Database database = new Database();
        database.connect();
        TareaDao tareaDao = new TareaDao(database.getConnection());
        tarea = tareaDao.get(id); // Asegúrate de tener este método en el DAO

        if (tarea != null) {
          duracionHoras = tarea.getDuracionHoras();
          costeEuros = tarea.getCosteEuros();
          descripcion = tarea.getDescripcion();
          terminado = tarea.isTerminado();
        }

      }
    } catch (NumberFormatException e) {
      response.sendRedirect("gestiontareas.jsp");
      return;
    }
  }
%>

<h2 class="mb-4"><%= rotulo %></h2>
<br>

<div class="container d-flex justify-content-center">
  <form action="tareas" method="POST" style="width: 50%; padding: 20px;" onsubmit="return validarFormulario()">

    <% if (modificando && tarea != null) { %>
    <input type="hidden" name="id" value="<%= tarea.getId() %>">
    <% } %>

    <div class="mb-3">
      <label for="duracionHoras" class="form-label">Duración (horas)</label>
      <input type="number" class="form-control" id="duracionHoras" name="duracionHoras" value="<%= duracionHoras %>" min="1" required>
    </div>

    <div class="mb-3">
      <label for="costeEuros" class="form-label">Coste (€)</label>
      <input type="number" class="form-control" id="costeEuros" name="costeEuros" value="<%= costeEuros %>" min="0" step="0.01" required>
    </div>

    <div class="mb-3">
      <label for="descripcion" class="form-label">Descripción</label>
      <textarea class="form-control" id="descripcion" name="descripcion" rows="3" required><%= descripcion %></textarea>
    </div>

    <div class="mb-3">
      <label for="terminado" class="form-label">¿Tarea terminada?</label>
      <select class="form-control" id="terminado" name="terminado" required>
        <option value="true" <%= terminado ? "selected" : "" %>>Sí</option>
        <option value="false" <%= !terminado ? "selected" : "" %>>No</option>
      </select>
    </div>

    <div class="d-flex justify-content-between">
      <button type="submit" class="btn btn-primary"><%= modificando ? "Actualizar" : "Registrar" %></button>
      <a href="listatareas.jsp" class="btn btn-secondary">Cancelar</a>
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

<%@ include file="includes/footer.jsp" %>

