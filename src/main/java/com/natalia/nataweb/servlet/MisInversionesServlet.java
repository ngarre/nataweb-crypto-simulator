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
import java.sql.Timestamp;

// A este servlet se llama para eliminar una inversión
@WebServlet("/misInversiones")
public class MisInversionesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String horaDeCierre = request.getParameter("horaDeCierre");
        String idUserStr = request.getParameter("idUser");

        if (horaDeCierre != null && idUserStr != null) {
            try {
                int idUser = Integer.parseInt(idUserStr);

                // Reemplazar la "T" por espacio para que sea un formato adecuado para la base de datos
                // Ejemplo: "2025-03-23T12:56:29" -> "2025-03-23 12:56:29"
                String formattedHoraDeCierre = horaDeCierre.replace("T", " ");

                // Convertir a Timestamp para asegurarnos que esté en el formato adecuado
                Timestamp timestamp = Timestamp.valueOf(formattedHoraDeCierre);

                // Conectar con la base de datos y eliminar la inversión
                Database database = new Database();
                database.connect();

                // Borro el registro de la inversión
                InversionDao inversionDao = new InversionDao(database.getConnection());
                inversionDao.deleteByUserIdAndHoraDeCierre(idUser, String.valueOf(timestamp));

                // Y ahora borro todos los registro de paquetes relacionados con esa inversión.
                PaqueteDao paqueteDao = new PaqueteDao(database.getConnection());
                paqueteDao.deleteByUserIdAndHoraDeCierre(idUser, timestamp);


                // Redirigir al mismo JSP con parámetro 'deleted=true'
                response.sendRedirect("misinversiones.jsp?deleted=true");

            } catch (SQLException | IllegalArgumentException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al eliminar la inversión");
            } catch (ClassNotFoundException e) {
                throw new RuntimeException(e);
            }
        } else {
            response.sendRedirect("misinversiones.jsp");
        }
    }

}
