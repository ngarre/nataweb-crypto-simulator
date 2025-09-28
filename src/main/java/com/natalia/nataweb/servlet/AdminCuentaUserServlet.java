package com.natalia.nataweb.servlet;


import com.natalia.nataweb.dao.InversionDao;
import com.natalia.nataweb.dao.PaqueteDao;
import com.natalia.nataweb.dao.UserDao;
import com.natalia.nataweb.database.Database;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/adminCuentaUser")
public class AdminCuentaUserServlet extends HttpServlet {

    // se le llama desde mantenimientocliente.jsp, cuando se cambia el estado de la cuenta a activo/desactivo
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Recuperar el parámetro 'username' de la URL (si está presente)
        String username = request.getParameter("username");

        // Recuperar el valor de 'cuentaActiva' del formulario
        String cuentaActivaStr = request.getParameter("cuentaActiva");
        boolean cuentaActiva = Boolean.parseBoolean(cuentaActivaStr);  // Convertirlo a booleano

        // Establecer la conexión con la base de datos
        Database database = new Database();
        try {
            database.connect();
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        UserDao userDao = new UserDao(database.getConnection());

        try {
            // Llamar al DAO para actualizar el estado de la cuenta activa
            boolean actualizado = userDao.updateAccountStatus(username, cuentaActiva);

            if (actualizado) {
                // Si la actualización fue exitosa, redirigir a una página de confirmación
                response.sendRedirect("gestionclientes.jsp");
            } else {
                // Si hubo algún error, redirigir con un mensaje de error
                String textoError = java.net.URLEncoder.encode("Error al cambiar el estado de la cuenta", "UTF-8");
                response.sendRedirect("errorgeneral.jsp?errorMessage=" + textoError);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // En caso de error, redirigir a la misma página con un error
            String textoError = java.net.URLEncoder.encode("Error al cambiar el estado de la cuenta", "UTF-8");
            response.sendRedirect("errorgeneral.jsp?errorMessage=" + textoError);
        }
    }

    // Método doGet para manejar la eliminación de un usuario
    // Se le lama desde gestionclientes.jsp.  desde el botón de eliminar.
        @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            String idParam = request.getParameter("id");

            if (idParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Falta el parámetro ID.");
                return;
            }

            try {
                int id = Integer.parseInt(idParam);  // convierto a int

                Database db = new Database();
                db.connect();
                UserDao userDao = new UserDao(db.getConnection());
                InversionDao inversionDao = new InversionDao(db.getConnection());
                PaqueteDao paqueteDao = new PaqueteDao(db.getConnection());

                inversionDao.deleteAllByUserId(id);
                paqueteDao.deleteAllByUserId(id);

                // Luego borrar el usuario

                boolean eliminado = userDao.deleteUserById(id);  // ahora elimina por ID

                if (eliminado) {
                    response.sendRedirect("gestionclientes.jsp?eliminado=ok");
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "No se pudo eliminar el usuario con ID " + id);
                }

            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID no válido.");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al eliminar el usuario.");
            }
        }



}

