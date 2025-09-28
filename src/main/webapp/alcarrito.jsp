<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="java.util.List" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>
<%@ page contentType="text/html;charset=UTF-8"  %>


<%@include file="includes/header.jsp"%>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("user")) {
        response.sendRedirect("/nataweb");
        return;
    }
%>


<%
        //String compraExitosa = request.getParameter("compraExitosa");

        List<Carrito> listaCarritos = (List<Carrito>) session.getAttribute("carritos");

        // Verifico si hay carritos en la sesión
        Carrito ultimoCarrito = null;
        // Obtengo el último carrito añadido
        ultimoCarrito = listaCarritos.get(listaCarritos.size() - 1);

%>

<div class="container d-flex justify-content-center">
    <div class='alert alert-success'>Añadido a su cartera con éxito</div>
</div>
    <br/>
<div class="container d-flex justify-content-center">
    <div class="mb-3">
        <h3>Detalles de la reserva de moneda</h3>
        <br/>
        <ul class="list-group list-group-flush">
            <li class="list-group-item">Nombre de la moneda: <%=ultimoCarrito.getNombreMoneda()%>
            </li>
            <li class="list-group-item">Cantidad: <%= ultimoCarrito.getCantidad()%>
            </li>
            <li class="list-group-item">Precio unitario: <%=  CurrencyUtils.format(ultimoCarrito.getPrecioUnitario())%></li>
            <li class="list-group-item">Precio total: <%= CurrencyUtils.format(ultimoCarrito.getPrecioTotal())%></li>
        </ul>
    </div>
</div>
<br>
<br>
<div class="container d-flex justify-content-center">
    <a href="index.jsp">
      <button type="button" class="btn btn-primary btn-lg">Continuar comprando</button>
    </a>
</div>



<%@include file="includes/footer.jsp"%>