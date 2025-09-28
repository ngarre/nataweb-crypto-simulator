package com.natalia.nataweb.servlet;

import com.natalia.nataweb.dao.CriptomonedaDao;
import com.natalia.nataweb.database.Database;
import com.natalia.nataweb.model.Criptomoneda;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.sql.SQLException;

@WebServlet("/registerMoneda")
@MultipartConfig
public class  RegisterMonedaServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Obtener los parámetros del formulario
        String nombre = request.getParameter("nombre");
        String descripcion = request.getParameter("descripcion");
        float precio = Float.parseFloat(request.getParameter("precio"));
        String procedencia = request.getParameter("procedencia");
        String riesgo = request.getParameter("riesgo");
        String rentabilidad = request.getParameter("rentabilidad");
        boolean habilitada = "true".equals(request.getParameter("habilitada"));

        // Verificar si se trata de una modificación o alta
        String idParam = request.getParameter("id");
        int id = (idParam != null && !idParam.isEmpty()) ? Integer.parseInt(idParam) : 0;

        // Utilizo el tipo requerido para imágenes, que es Part
        // Aquí se caza el nombre del archivo (ruta) y su tamaño
        Part part = request.getPart("imagenfoto");
        // Preparo una variable para cargar el flujo de datos de la imagen (bytes)
        InputStream inputStream = null;

        // Si se seleccionó una imagen, obtener el InputStream
        if (part != null && part.getSize() > 0) {
            // Si el archivo tiene tamaño, entonces lo cargo
            inputStream = part.getInputStream();
        }

        // Crear el objeto Criptomoneda
        Criptomoneda cmoneda = new Criptomoneda();
        cmoneda.setId(id);
        cmoneda.setNombre(nombre);
        cmoneda.setDescripcion(descripcion);
        cmoneda.setPrecio(precio);
        cmoneda.setProcedencia(procedencia);
        cmoneda.setRiesgo(riesgo);
        cmoneda.setRentabilidad(rentabilidad);
        cmoneda.setHabilitada(habilitada);

        if (inputStream != null) {
            cmoneda.setImagenFoto(inputStream); // Solo se establece la imagen si se seleccionó una
        }

        // Crear conexión a la base de datos
        try {
            Database database = new Database();
            database.connect();
            CriptomonedaDao cmonedaDao = new CriptomonedaDao(database.getConnection());

            boolean success = false;

            if (id > 0) {
                // Si id > 0, es una actualización
                // Verificar si ya existe el nombre de la criptomoneda antes de actualizar
                Criptomoneda existingCriptomoneda = cmonedaDao.getByNombre(nombre);
                if (existingCriptomoneda != null && existingCriptomoneda.getId() != id) {
                    // Si ya existe otra criptomoneda con el mismo nombre y es diferente de la actual
                    response.setContentType("text/plain");
                    response.getWriter().write("Ya existe una criptomoneda con este nombre.");
                    return; // Salir si hay conflicto de nombre
                }

                success = cmonedaDao.updateMoneda(cmoneda);
            } else {
                // Si id == 0, es una inserción
                // Verificar si ya existe una criptomoneda con el mismo nombre antes de insertar
                Criptomoneda existingCriptomoneda = cmonedaDao.getByNombre(nombre);
                if (existingCriptomoneda != null) {

                    // Si ya existe una criptomoneda con el mismo nombre
                    response.setContentType("text/plain");
                    response.getWriter().write("Ya existe una criptomoneda con este nombre.");
                    return; // Salir si hay conflicto de nombre
                }

                success = cmonedaDao.insertMoneda(cmoneda);
            }

            if (success) {
                // Respuesta satisfactoria
                response.setContentType("text/plain");
                response.getWriter().write("ok");
            } else {
                // Si la operación falla por algún motivo
                response.setContentType("text/plain");
                response.getWriter().write("Error en la operación");
            }

        } catch (SQLException | ClassNotFoundException e) {
            // Si hay un error en la base de datos o al conectar
            e.printStackTrace();
            response.setContentType("text/plain");
            response.getWriter().write("Hubo un error en la base de datos. Intente nuevamente.");
        }
    }

    // Este método maneja la eliminación de criptomonedas
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Obtener el id de la criptomoneda desde la URL
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);

                // Crear la conexión con la base de datos
                Database database = new Database();
                database.connect();

                // Crear el DAO y eliminar la criptomoneda
                CriptomonedaDao cmonedaDao = new CriptomonedaDao(database.getConnection());
                boolean success = cmonedaDao.deleteMoneda(id);


                if (success) {
                    // Redirigir de vuelta a la página de gestión de monedas
                    response.sendRedirect("gestionmonedas.jsp?eliminado=ok");
                } else {
                    String textoError = java.net.URLEncoder.encode("Nada eliminado", "UTF-8");
                    response.sendRedirect("errorgeneral.jsp?errorMessage=" + textoError);
                }

            } catch (NumberFormatException | SQLException | ClassNotFoundException e) {
                e.printStackTrace();
                response.setContentType("text/plain");
                response.getWriter().write("Hubo un error al procesar la solicitud.");
            }
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("ID no válido");
        }
    }
}
