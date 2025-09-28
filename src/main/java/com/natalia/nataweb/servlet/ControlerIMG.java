package com.natalia.nataweb.servlet;

import com.natalia.nataweb.dao.CriptomonedaDao;
import com.natalia.nataweb.database.Database;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/ControlerIMG")
public class ControlerIMG extends HttpServlet {

    private CriptomonedaDao criptomonedaDao;
    private Connection connection;  // Declaramos la conexión a la base de datos

    // LEEME...
    // es más eficiente usar métodos init() y destroy()
    // según veo en diversas documentaciones optimiza mejor los recursos de la aplicación y del servidor
    // y es más eficiente.
    // ...
    // en tanto en cuanto la salida de imágenes es un proceso muy repetitivo y lanzado de manera masiva
    // al contrario que la llamada a otros servlets operativos que llaman a dao's, decido usar esta
    // opción con este servlet que utilizo para mostrar recuperar imágenes y poder displayarlas.



    @Override
    public void init() throws ServletException {
        try {
            // Inicializa la conexión a la base de datos y el DAO
            Database database = new Database();
            database.connect();
            connection = database.getConnection(); // Guardamos la conexión en la variable de clase
            criptomonedaDao = new CriptomonedaDao(connection);
        } catch (SQLException | ClassNotFoundException e) {
            throw new ServletException("Error al conectar con la base de datos", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Obtengo el id de la criptomoneda
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID no proporcionado");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);

            // Recupero la imagen del DAO
            InputStream imageStream = criptomonedaDao.getImagen(id);
            if (imageStream != null) {
                response.setContentType("image/jpeg"); // Ajustar tipo según la imagen

                // Y ahora, leo el contenido de ese campo de la base de datos.
                // Sintaxis habitual de lectura de archivos

                try (BufferedInputStream in = new BufferedInputStream(imageStream);
                     BufferedOutputStream out = new BufferedOutputStream(response.getOutputStream())) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {

                        // Voy creando el stream que va a devolver los datos al controlador
                        // Que a su vez devolverá la imagen final al JSP
                        out.write(buffer, 0, bytesRead);
                    }

                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Imagen no encontrada");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
        } catch (SQLException e) {
            throw new ServletException("Error al obtener la imagen de la base de datos", e);
        }
    }

    @Override
    public void destroy() {

        // Cierra la conexión cuando el servlet se destruye
        try {
            if (connection != null) {
                connection.close();  // Cierra la conexión a la base de datos
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
