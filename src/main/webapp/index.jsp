<%@ page import="com.natalia.nataweb.database.Database" %>
<%@ page import="com.natalia.nataweb.dao.CriptomonedaDao" %>
<%@ page import="com.natalia.nataweb.model.Criptomoneda" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.natalia.nataweb.model.Carrito" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.natalia.nataweb.utils.CurrencyUtils" %>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@include file="includes/header.jsp"%>


<%--FORMULARIO HTML BÚSQUEDAS POR RENTABILIDAD Y RIESGO--%>
<div class="container mt-4">
    <div class="d-flex justify-content-end">
        <form action="index.jsp" method="GET" class="d-flex align-items-center gap-3">
            <div class="d-flex align-items-center">
                <label for="criterio1" class="me-2" style="font-size: 0.85rem;">Rentabilidad:</label>
                <select id="criterio1" name="criterio1" class="form-select form-select-sm"
                        style="width: 150px; font-size: 0.85rem;">
                    <option value="">Todas</option>
                    <option value="alta" <%= "alta".equalsIgnoreCase(request.getParameter("criterio1")) ? "selected" : "" %>>Alta</option>
                    <option value="media" <%= "media".equalsIgnoreCase(request.getParameter("criterio1")) ? "selected" : "" %>>Media</option>
                    <option value="baja" <%= "baja".equalsIgnoreCase(request.getParameter("criterio1")) ? "selected" : "" %>>Baja</option>
                </select>
            </div>

            <div class="d-flex align-items-center">
                <label for="criterio2" class="me-2" style="font-size: 0.85rem;">Riesgo:</label>
                <select id="criterio2" name="criterio2" class="form-select form-select-sm"
                        style="width: 150px; font-size: 0.85rem;">
                    <option value="">Todos</option>
                    <option value="bajo" <%= "bajo".equalsIgnoreCase(request.getParameter("criterio2")) ? "selected" : "" %>>Bajo</option>
                    <option value="medio" <%= "medio".equalsIgnoreCase(request.getParameter("criterio2")) ? "selected" : "" %>>Medio</option>
                    <option value="alto" <%= "alto".equalsIgnoreCase(request.getParameter("criterio2")) ? "selected" : "" %>>Alto</option>
                </select>
            </div>

            <button type="submit" class="btn btn-sm btn-primary" style="font-size: 0.85rem;">Buscar</button>
        </form>
    </div>
</div>

<br>


<div class="pricing-header p-3 pb-md-4 mx-auto text-center">
    <h1 class="display-4 fw-normal text-body-emphasis">Mejores criptomonedas</h1>
    <p class="fs-5 text-body-secondary">Regístrese como usuario de nuestra web y acceda a la posibilidad de adquirir un
        rentable paquete conformado en las más rentables criptomonedas en el mercado</p>

<%--    BOTÓN ACTUALIZACIÓN COTIZACIONES--%>
    <div class="container d-flex justify-content-center">
        <div class="card mb-4 rounded-3">
            <form action="actualizaCotizacion" method="POST">
                <button type="submit" class="btn btn-lg btn-outline-danger">Actualizar cotizaciones</button>
            </form>
        </div>
    </div>

</div>


<div class="row row-cols-1 row-cols-md-3 mb-3 text-center">

           <%
             // Recupero la lista de carritos de la sesión
             // Esto sirve para que si el cliente ya ha comprado alguna moneda. la correspondiente
             // salga ya marcada o deshabilitada para la compra
             List<Carrito> listaCarritos = (List<Carrito>) session.getAttribute("carritos");
             if (listaCarritos == null) {
                listaCarritos = new ArrayList<>(); // Lista vacía si no existe
              }
            %>

            <%
                Database database = new Database();
                try {

                    database.connect();
                    CriptomonedaDao cmonedaDao = new CriptomonedaDao(database.getConnection());

                    // Estos parámetros se recuperan en el caso de que se fuerce una búsqueda, sino estarán nulos
                    String criterio1 = request.getParameter("criterio1");
                    String criterio2 = request.getParameter("criterio2");

                    List<Criptomoneda> listaCriptomonedas;

                    if ((criterio1 != null && !criterio1.trim().isEmpty()) || (criterio2 != null && !criterio2.trim().isEmpty())) {
                      listaCriptomonedas = cmonedaDao.buscarPorCriterios(criterio1, criterio2);
                    } else {
                      listaCriptomonedas = cmonedaDao.getAll(true);
                    }

                    // Repetitiva de recorrer todas y cada una de las monedas para pintarlas
                    for (Criptomoneda cmoneda : listaCriptomonedas) {


                    boolean isComprada = false;

                    // Si hay carritos en la sesión, verificar si el idCripto de alguno coincide con el de la criptomoneda
                    for (Carrito carrito : listaCarritos) {
                    if (carrito.getIdCripto() == cmoneda.getId()) {
                       isComprada = true;
                       break; // Si encontramos una coincidencia, no necesitamos seguir buscando
                    }

            }

            %>

            <div class="col">
                <div class="card mb-4 rounded-3">
<%--                    <div class="card-header py-3">--%>
<%--                        <h4 class="my-0 fw-normal"><img src="imagenes/monedas/<%= cmoneda.getImagen() %>"></h4>--%>
<%--                    </div>--%>
                    <div class="card-header py-3">
                        <h4 class="my-0 fw-normal">
<%--                            <img src="imagenes/monedas/<%= cmoneda.getImagen() %>">--%>
                            <img src="<%= request.getContextPath() %>/ControlerIMG?id=<%= cmoneda.getId() %>">
                        </h4>
                    </div>

                    <div class="card-body">
                        <h1 class="card-title pricing-card-title"><%= cmoneda.getNombre() %></h1>
                        <ul class="list-unstyled mt-3 mb-4">
                            <li>
                                <h5 class="card-title pricing-card-title"><%= CurrencyUtils.format(cmoneda.getPrecio()) %></h5>
                            </li>
                            <li>Rentabilidad <%= cmoneda.getRentabilidad() %></li>
<%--                            <li>- Riesgo <%= cmoneda.getRiesgo() %>-</li>--%>
                            <li>- Riesgo <span class="text-danger fw-bold"><%= cmoneda.getRiesgo() %></span> -</li>
                        </ul>

                        <a href="<%= isComprada ? "#" : "infomoneda.jsp?id=" + cmoneda.getId() %>"
                           class="w-100 btn btn-lg <%= isComprada ? "btn-success disabled" : "btn-outline-primary" %>"
                                <%= isComprada ? "tabindex='-1'" : "" %> >
                            <%= isComprada ? "Comprada" : "Más información..." %>
                        </a>

                    </div>
                </div>
            </div>

            <%
                }
            } catch (ClassNotFoundException cnfe) {
                cnfe.printStackTrace();
            %>
            <div>
                Error al conectar con la base de datos. Fallo con el driver
            </div>
            <%
            } catch (SQLException sqle) {
                sqle.printStackTrace();
            %>
            <div>
                Error al conectar con la base de datos. Comprueba que está iniciada y la configuración es correcta
            </div>
            <%
                }
            %>



    <%@include file="includes/footer.jsp"%>

