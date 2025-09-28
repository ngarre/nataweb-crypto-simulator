<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CriptomonedaDao" %>
<%@ page import="com.natalia.nataweb.model.Criptomoneda" %>
<%@ page import="com.natalia.nataweb.exception.MonedaNoEncontradaException" %>
<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="java.util.List" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page import="java.sql.SQLException" %>
<%@ page contentType="text/html;charset=UTF-8"  %>


<%@include file="includes/header.jsp"%>

<script>
    function validarCantidad() {
        var cantidad = document.getElementById("cantidad").value;

        // Expresión regular: solo dígitos enteros del 1 al 10
        var regex = /^(10|[1-9])$/;

        if (!regex.test(cantidad)) {
            alert("Por favor, introduce un número entero entre 1 y 10, sin decimales.");
            return false;
        }

        return true;
    }
</script>



<%
    int monedaId = Integer.parseInt((request.getParameter("id")));
    Database database = new Database();
    database.connect();
    CriptomonedaDao criptomonedaDao = new CriptomonedaDao(database.getConnection());

    try {
    Criptomoneda cmoneda = criptomonedaDao.get(monedaId);



 %>

<br>
<br>

<div class="container d-flex justify-content-center">
    <!-- Row con solo una columna para el centro -->
    <div class="row justify-content-center">
        <div class="col-md-6 col-12" style="min-width: 500px;">
            <div class="card mb-4 rounded-3 shadow-sm">
                <div class="card-header py-3 text-center">
                    <img src="<%= request.getContextPath() %>/ControlerIMG?id=<%= cmoneda.getId() %>" alt="<%= cmoneda.getNombre() %>" class="img-fluid d-block mx-auto">
                </div>
                <div class="card-body">
                    <h1 class="card-title pricing-card-title"><%= cmoneda.getNombre() %>
                    </h1>

                    <ul class="list-unstyled mt-3 mb-4">
                        <li>&nbsp;</li>
                        <li>
                            <h5 class="card-title pricing-card-title"><%= CurrencyUtils.format(cmoneda.getPrecio()) %>
                        </li>

                        <li>
                            Compra máxima = 10 unidades
                        </li>
                        <hr>
                        <br>

                        <li style="min-height: 4rem;">
                            <%= cmoneda.getDescripcion() %>
                        </li>

                        <li>&nbsp;</li>
                    </ul>


                    <%
                        String role = (String) session.getAttribute("role");
                    %>

                    <% if ("user".equals(role)) { %>
                    <form action="carrito" method="POST" onsubmit="return validarCantidad()">
                        <div class="row g-3 align-items-center mb-4">
                            <div class="col-auto">
                                <label for="cantidad" class="col-form-label">Cantidad</label>
                            </div>
                            <div class="col-auto">
                                <input type="text" name="cantidad" id="cantidad"  class="form-control" style="width: 30%;"
                                       aria-describedby="passwordHelpInline">
                            </div>
                        </div>

                        <!-- Nombre de la moneda -->
                        <input type="hidden" name="nombreMoneda" value="<%= cmoneda.getNombre() %>">
                        <!-- Precio de la moneda -->
                        <input type="hidden" name="precioMoneda" value="<%= cmoneda.getPrecio() %>">
                        <!-- id de la moneda -->
                        <input type="hidden" name="monedaId" value="<%= monedaId %>">


                        <button type="submit" class="w-100 btn btn-lg btn-outline-primary">Comprar</button>
                    </form>
                    <% } else if ("admin".equals(role)) { %>
                    <button type="button" class="w-100 btn btn-lg btn-outline-primary" disabled>Opción reservada a clientes</button>
                    <% } else { %>
                    <a href="login.jsp" class="w-100 btn btn-lg btn-outline-primary">Inicia Sesión para comprar</a>
                    <% } %>


                </div>
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