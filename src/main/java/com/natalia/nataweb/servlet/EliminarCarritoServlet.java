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

@WebServlet("/eliminarCarrito")
public class EliminarCarritoServlet extends HttpServlet {
        protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            // Obtener el idCripto desde la URL
            int idCripto = Integer.parseInt(request.getParameter("idCripto"));

            // Obtener la lista de carritos de la sesión
            HttpSession session = request.getSession();
            List<Carrito> listaCarritos = (List<Carrito>) session.getAttribute("carritos");


            if (listaCarritos != null) {
                // Iterar sobre la lista de carritos para encontrar el carrito con el idCripto
                listaCarritos.removeIf(carrito -> carrito.getIdCripto() == idCripto);

                // Actualizar la lista de carritos en la sesión
                session.setAttribute("carritos", listaCarritos);
            }

            // Redirigir a la página de listado de carritos para refrescar
            response.sendRedirect("gestioncarrito.jsp");
        }

    }
