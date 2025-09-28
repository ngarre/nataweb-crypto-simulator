<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page contentType="text/html;charset=UTF-8"  %>

<%@include file="includes/header.jsp"%>

<style>
    .table-like {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
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
    .no-items {
        text-align: center;
        font-size: 18px;
        color: #ff6347; /* Color rojo */
    }

    /* Estilo para el contenedor del total de la compra */
    .total-container {
        margin-top: 20px; /* Espacio entre la tabla y el total */
        font-size: 1.25em; /* Aumentar el tamaño del texto */
        font-weight: bold; /* Hacer el texto más grueso */
        text-align: left; /* Alinear el texto completamente a la izquierda */
    }

    /* Estilo para el valor del total */
    .total-value {
        color: #4caf50; /* Color verde para resaltar el total */
        font-size: 1.5em; /* Aumenta el tamaño del número */
        margin-left: 10px; /* Espacio entre el texto y la cifra */
    }

    /* Estilo para el botón */
    .complete-button {
        margin-top: 20px;
        text-align: center;
    }
</style>

<%

    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("user")) {
        response.sendRedirect("/nataweb");
        return;
    }


    // Crear un objeto DecimalFormat para mostrar los números con dos decimales
    // DecimalFormat formato = new DecimalFormat("#.00");
    // Voy a usar el modo que ha propuesto Santi. Está mucho mejor.

    // Obtener la lista de carritos desde la sesión
    List<Carrito> listaCarritos = (List<Carrito>) session.getAttribute("carritos");

    // Variable para almacenar el total
    double totalCompra = 0.0;

    // Obtener saldo de sesión
    float saldo = (Float) session.getAttribute("saldo");

    // Verificar si la lista está vacía o no existe
    if (listaCarritos == null || listaCarritos.isEmpty()) {
%>

<h2 class="mb-4">No hay monedas en su cartera</h2>

<br>
<br>
<br>
<br>
<br>

<div class="container d-flex justify-content-center">
    <a href="index.jsp">
        <button type="button" class="btn btn-primary btn-lg">Seleccione sus monedas</button>
    </a>
</div>

<%
} else {
%>

<div class="container">
    <div class="table-like">

        <!-- Encabezado de la tabla -->
        <div class="header">Moneda</div>
        <div class="header">Cantidad</div>
        <div class="header">Precio Unitario</div>
        <div class="header">Precio Total</div>
        <div class="header">Eliminar</div> <!-- Columna extra para el botón -->

        <%
            // Itero la lista de carritos y muestro cada moneda en una fila
            for (Carrito carrito : listaCarritos) {
                // Sumar el precio total de cada artículo
                totalCompra += carrito.getPrecioTotal();
        %>
        <!-- Fila de cada carrito -->
        <div class="item"><%= carrito.getNombreMoneda() %></div>
        <div class="item"><%= carrito.getCantidad() %></div>
        <div class="item"><%= CurrencyUtils.format(carrito.getPrecioUnitario()) %></div>
        <div class="item"><%= CurrencyUtils.format(carrito.getPrecioTotal()) %></div>
        <div class="item">
            <!-- Botón de eliminar con confirmación antes de proceder -->
            <a href="eliminarCarrito?idCripto=<%= carrito.getIdCripto() %>" class="btn btn-danger btn-sm"
               onclick="return confirm('¿Estás seguro de que quieres eliminar este artículo del carrito?')">
                Eliminar
            </a>
        </div>
        <% }  %>

    </div>

    <!-- Total de la compra alineado a la izquierda fuera de la tabla -->
    <div class="total-container">
        <strong>Total de la compra: </strong>
        <span class="total-value"><%= CurrencyUtils.format(totalCompra) %></span>
    </div>

    <!-- Formulario oculto para enviar los datos al servlet -->
    <%--    Hay algunos datos que están en sesión y el servlet los cogerá de ahí pero hay --%>
    <%--    otros como el totalCompra y el modo="terminar" que los necesita también el servlet--%>
    <%--    por eso los pongo aquí ocultos, para que se envién también y no se vean en el formulario--%>
    <form id="completarInversionForm" action="actualizaCotizacion" method="post">
        <input type="hidden" name="totalCompra" value="<%= CurrencyUtils.format(totalCompra) %>">
        <input type="hidden" name="saldo" value="<%= saldo %>">
        <input type="hidden" name="modo" value="terminar">
    </form>

    <!-- Botón de "Completar la inversión" centrado en el container -->
    <div class="complete-button">
        <button type="button" class="btn btn-primary btn-lg" onclick="validarSaldo()">Terminar la inversión</button>
    </div>

    <br>

    <!-- Botón "Seguir comprando" debajo del botón de terminar inversión -->
    <div class="complete-button">
        <a href="index.jsp">
            <button type="button" class="btn btn-success btn-lg">Seguir comprando</button>
        </a>
    </div>

    <br>
    <br>
    <br>

</div>

<%
    }
%>

<!-- Modal para mostrar el mensaje de advertencia -->
<div class="modal fade" id="warningModal" tabindex="-1" aria-labelledby="warningModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="warningModalLabel">Aviso importante</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>El total de la compra es mayor que el saldo disponible. No tienes saldo suficiente para completar la inversión.</p>
            </div>
            <div class="modal-footer">
                <!-- El botón de "Aceptar" ya no redirige a ninguna página, solo cierra el modal -->
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<script>
    // Función que valida el saldo
    function validarSaldo() {
        var saldo = <%= saldo %>; // Obtener saldo de sesión
        var totalCompra = <%= totalCompra %>; // Obtener el total de la compra

        if (totalCompra > saldo) {
            // Si el saldo es insuficiente, mostramos el modal de Bootstrap
            var myModal = new bootstrap.Modal(document.getElementById('warningModal'), {
                keyboard: false
            });
            myModal.show(); // Muestra el modal
        } else {
            // Si el saldo es suficiente, enviamos el formulario
            document.getElementById('completarInversionForm').submit();
        }
    }
</script>

<%@include file="includes/footer.jsp"%>
