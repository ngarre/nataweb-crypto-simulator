<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="includes/header.jsp"%>


<!-- Agregar Bootstrap JS (y Popper.js para los modales) -->
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.min.js"></script>

<!-- Script de jQuery para manejar la validación y mostrar el modal -->
<script type="text/javascript">
    $(document).ready(function() {
        $("form").on("submit", function(event) {
            event.preventDefault();
            const formValue = $(this).serialize();
            $.ajax("login", {
                type: "POST",
                data: formValue,
                statusCode: {
                    200: function(response) {
                        if (response === "ok") {
                            window.location.href = "/nataweb"; // Redirige a la página principal para usuarios normales
                        } else {
                            // Muestra el mensaje de error en el modal
                            $("#modalErrorMessage").text(response);
                            $("#errorModal").modal('show'); // Muestra el modal
                        }
                    }
                }
            });
        });
    });
</script>


<!-- Modal para mostrar el mensaje de error -->
<div class="modal fade" id="errorModal" tabindex="-1" aria-labelledby="errorModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="errorModalLabel">Error en la Autentificación</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="modalErrorMessage"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>



<!-- El resto del código HTML (el formulario) -->
<p>&nbsp;</p>
<div class="container d-flex justify-content-center">
    <form>
        <h1 class="h3 mb-3 fw-normal text-center" style="width: 150%;" >Iniciar sesión</h1>
        <div class="form-floating mb-3" style="width: 150%;">
            <input type="text" name="username" class="form-control" id="floatingInput" placeholder="nombre de usuario">
            <label for="floatingInput">nombre de usuario</label>
        </div>
        <div class="form-floating mb-3" style="width: 150%;">
            <input type="password" name="password" class="form-control" id="floatingPassword" placeholder="Password">
            <label for="floatingPassword">Password</label>
        </div>
        <button class="btn btn-primary" type="submit" style="width: 150%; padding: 0.75rem;">Entrar</button>
    </form>
</div>



<%@include file="includes/footer.jsp"%>