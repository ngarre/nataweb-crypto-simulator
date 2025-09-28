<%@ page import="javax.swing.*" %>
<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.UserDao" %>
<%@ page import="com.natalia.nataweb.model.User" %>
<%@ page import="com.natalia.nataweb.exception.ClienteNoEncontradoException" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/header.jsp"%>

<style>
    .bold-input {
        font-weight: bold;
    }
</style>

<script type="text/javascript">
    $(document).ready(function() {
        $("form").on("submit", function(event) {
            event.preventDefault();  // Evita el envío del formulario

            var edad = parseInt($("#edad").val(), 10);


            // Validación de la edad
            if (edad < 18) {
                if (!$("#errorModal").hasClass("show")) {
                    $("#modalErrorMessage").text("La edad debe ser 18 años o más para poder registrarse.");
                    $("#errorModal").modal('show');
                }
                return;  // Detenemos el flujo y no enviamos el formulario
            }

            // Validación del saldo

            var saldoRaw = $("#saldo").val().trim();
            // Reemplazar coma por punto para que parseFloat funcione correctamente
            var saldo = saldoRaw.replace(",", ".");

            if (isNaN(saldo) || saldo.trim() === "" || parseFloat(saldo) <= 0) {
                if (!$("#errorModal").hasClass("show")) {
                    $("#modalErrorMessage").text("Por favor, introduce un valor numérico válido para el saldo.");
                    $("#errorModal").modal('show');
                }
                return;  // Detenemos el flujo y no enviamos el formulario
            }

            $("#saldo").val(saldo);  // Actualiza el campo para que serialize() lo tome corregido

            // Validación de las contraseñas
            var password = $("#password").val();
            var repeatPassword = $("#repeat-password").val();

            if (password !== repeatPassword) {
                if (!$("#errorModal").hasClass("show")) {
                    $("#modalErrorMessage").text("Las contraseñas no coinciden. Por favor, verifica los campos.");
                    $("#errorModal").modal('show');
                }
                return;  // Detenemos el flujo y no enviamos el formulario
            }




            // Si las validaciones pasan, realizamos el envío del formulario (AJAX)
            const formValue = $(this).serialize();

            $.ajax({
                url: "registerUser",
                type: "POST",
                data: formValue,
                statusCode: {
                    200: function(response) {
                        if (response === "ok") {
                            $("#modalSuccessMessage").text("¡Operación correcta! Acepte para continuar");
                            $("#successModal").modal('show');

                            $('#btnAcceptSuccess').one('click', function() {
                                $('#successModal').modal('hide');

                                // Verificar si estamos actualizando o dando de alta
                                <% if (isSessionActive) { %>
                                // Si es una actualización (usuario está logueado), redirigir a la página principal
                                window.location.href = "/nataweb";
                                <% } else { %>
                                // Si es un alta, redirigir al login
                                window.location.href = "login.jsp";
                                <% } %>
                            });
                        } else {
                            $("#modalErrorMessage").text(response);
                            $("#errorModal").modal('show');
                        }
                    }
                }
            });
        });

        // Asegurar que el botón de aceptar en el modal de error lo cierre correctamente
        $('#btnAcceptError').on('click', function() {
            $("#errorModal").modal('hide');  // Cierra el modal
        });
    });
</script>



<%
    String rotulo;
    String usuarioNickname = "";
    String usuarioNombre = "";
    String usuarioEmail = "";
    String usuarioApellidos = "";
    String usuarioCiudad = "";
    String usuarioEdad = "";  // Nuevo campo edad
    float usuarioSaldo = 0;
%>

<%
    rotulo = "Registro de Cliente";

    if (isSessionActive) {

        String nombreUsuario = (String) session.getAttribute("username");
        rotulo = "Mi perfil de cliente";

        Database database = new Database();
        database.connect();

        UserDao userDao = new UserDao(database.getConnection());
        User usuario = userDao.get(nombreUsuario);
        usuarioNickname = usuario.getUsername();
        usuarioNombre = usuario.getNombre();
        usuarioApellidos = usuario.getApellidos();
        usuarioCiudad = usuario.getCiudad();
        usuarioEdad = String.valueOf(usuario.getEdad());  // Obtener la edad
        usuarioEmail = usuario.getEmail();
        usuarioSaldo = usuario.getSaldo();
    }
%>

<h2 class="mb-4"><%= rotulo %></h2>

<div class="container d-flex justify-content-center">
    <!-- Formulario de registro -->
    <form enctype="multipart/form-data" style="width: 50%; padding: 20px;">
        <!-- Campo de nickname -->
        <div class="mb-3">
            <label for="nickname" class="form-label">Nickname</label>

            <% if (isSessionActive) { %>
            <input type="text" class="form-control-plaintext bold-input text-white" style="background-color: orange; padding: 0.375rem 0.75rem; border-radius: 0.375rem;" id="nickname" name="nickname" value="<%= usuarioNickname %>" readonly>
            <% } else { %>
            <input type="text" class="form-control bold-input" id="nickname" name="nickname" required>
            <% } %>
        </div>

        <!-- Campos de contraseñas en la misma línea -->
        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="password" class="form-label">Contraseña</label>
                <input type="password" class="form-control bold-input" id="password" name="password" required>
            </div>
            <div style="flex: 1;">
                <label for="repeat-password" class="form-label">Repetir Contraseña</label>
                <input type="password" class="form-control bold-input" id="repeat-password" name="repeat-password" required>
            </div>
        </div>

        <!-- Campos de nombre y apellidos en la misma línea -->
        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="nombre" class="form-label">Nombre</label>

                <% if (isSessionActive) { %>
                <input type="text" class="form-control bold-input" id="nombre" name="nombre" value="<%= usuarioNombre %>" required>
                <% } else { %>
                <input type="text" class="form-control bold-input" id="nombre" name="nombre" required>
                <% } %>
            </div>
            <div style="flex: 1;">
                <label for="apellidos" class="form-label">Apellidos</label>

                <% if (isSessionActive) { %>
                <input type="text" class="form-control bold-input" id="apellidos" name="apellidos" value="<%= usuarioApellidos %>" required>
                <% } else { %>
                <input type="text" class="form-control bold-input" id="apellidos" name="apellidos" required>
                <% } %>
            </div>
        </div>

        <!-- Campos de ciudad y edad en la misma línea -->
        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="ciudad" class="form-label">Ciudad</label>

                <% if (isSessionActive) { %>
                <input type="text" class="form-control bold-input" id="ciudad" name="ciudad" value="<%= usuarioCiudad %>" required>
                <% } else { %>
                <input type="text" class="form-control bold-input" id="ciudad" name="ciudad" required>
                <% } %>
            </div>

            <div style="flex: 1;">
                <label for="edad" class="form-label">Edad</label>
                <% if (isSessionActive) { %>
                <input type="number" class="form-control bold-input" id="edad" name="edad" value="<%= usuarioEdad %>" required>
                <% } else { %>
                <input type="number" class="form-control bold-input" id="edad" name="edad" required>
                <% } %>
            </div>
        </div>

        <!-- Campos de saldo y email en la misma línea -->
        <div class="mb-3 d-flex gap-3">
            <div style="flex: 1;">
                <label for="saldo" class="form-label">Saldo aportado</label>

                <% if (isSessionActive) { %>
                <input type="text" class="form-control bold-input" id="saldo" name="saldo" value="<%= usuarioSaldo %>" required>
                <% } else { %>
                <input type="text" class="form-control bold-input" id="saldo" name="saldo" required>
                <% } %>
            </div>

            <div style="flex: 1;">
                <label for="email" class="form-label">Email</label>

                <% if (isSessionActive) { %>
                <input type="email" class="form-control bold-input" id="email" name="email" value="<%= usuarioEmail %>" required>
                <% } else { %>
                <input type="email" class="form-control bold-input" id="email" name="email" required>
                <% } %>

                <div class="invalid-feedback">
                    Por favor, introduce una dirección de correo válida.
                </div>
            </div>
        </div>

        <div class="mb-3 d-flex gap-3"> <br></div>

        <!-- Botones de Aceptar y Cancelar -->
        <div class="d-flex justify-content-between">
            <% if (isSessionActive) { %>
            <button type="submit" class="btn btn-primary">Actualizar</button>
            <% } else { %>
            <button type="submit" class="btn btn-primary">Aceptar</button>
            <% } %>

            <a href="/nataweb" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!-- Modal de éxito -->
<div id="successModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="successModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="successModalLabel">Operación exitosa</h5>
            </div>
            <div class="modal-body">
                <p id="modalSuccessMessage">¡La operación fue exitosa!</p>
            </div>
            <div class="modal-footer">
                <button type="button" id="btnAcceptSuccess" class="btn btn-primary">Aceptar</button>
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
                <p id="modalErrorMessage">Hubo un error en la operación.</p>
            </div>
            <div class="modal-footer">
                <button type="button" id="btnAcceptError" class="btn btn-primary">Aceptar</button>
            </div>
        </div>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
