package com.natalia.nataweb.servlet;

import com.natalia.nataweb.model.Carrito;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


import java.io.IOException;


import java.util.List;
import java.util.ArrayList;

@WebServlet("/carrito")
public class CarritoServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Obtengo los parámetros enviados desde el formulario: infomoneda.jsp
        // es decir cuando se compran en infomoneda.jsp una cantidad de una moneda se va guardando
        // en una variable de sesión

        String nombreMoneda = request.getParameter("nombreMoneda");
        int cantidad = Integer.parseInt(request.getParameter("cantidad"));
        int monedaId = Integer.parseInt(request.getParameter("monedaId"));
        float precioMoneda = Float.parseFloat(request.getParameter("precioMoneda"));
        System.out.println("cantidad: " + cantidad);

        // Crear una nueva instancia de Carrito con los datos recibidos
        Carrito carrito = new Carrito();
        carrito.setNombreMoneda(nombreMoneda);
        carrito.setCantidad(cantidad);
        carrito.setIdCripto(monedaId);

        HttpSession session = request.getSession();
        int idUsuario = (int) session.getAttribute("id");  // lo saco de la sesión
        carrito.setIdUsuario(idUsuario);

        carrito.setPrecioUnitario(precioMoneda);
        carrito.setPrecioTotal(cantidad * precioMoneda); // Calcular precio total
        carrito.setPrecioActualizado(0);  // este se actualiza al completar la inversión

        // a partir de ahora voy a guardar el carrito en la sesión
        session = request.getSession();

        // primero recupero el posible carrito que pudiera existir con otras monedas
        List<Carrito> listaCarritos = (List<Carrito>) session.getAttribute("carritos");

        // Si no hay una lista de carritos en la sesión, crear una nueva
        // Creo el objeto java colección ArrayList<> pàra el carrito.
        if (listaCarritos == null) {
            listaCarritos = new ArrayList<>();
        }
        // Añadir el nuevo carrito a la lista
        listaCarritos.add(carrito);

        // Guardar la lista actualizada de carritos en la sesión.  Esto significa: guarda la lista de carritos en la sesión del usuario bajo la clave 'carritos'
        session.setAttribute("carritos", listaCarritos);

        // Redirigir a la página de monedas disponibles
        // response.sendRedirect("/nataweb");  // O la página donde se mostrará el carrito
        //response.sendRedirect("alcarrito.jsp?compraExitosa=true");
        response.sendRedirect("alcarrito.jsp");

    }


}



