package com.natalia.nataweb.servlet;

import com.natalia.nataweb.dao.OpinionDao;
import com.natalia.nataweb.database.Database;
import com.natalia.nataweb.model.Opinion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/misOpiniones")
public class OpinionesServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");
        int userId = Integer.parseInt(userIdStr);

        // Obtener los parámetros del formulario
        String horadecierre = request.getParameter("horadecierre");
        String ganancia = request.getParameter("ganancia");
        String descripcion = request.getParameter("descripcion");
        String expectativaString = request.getParameter("expectativa");  // Recibir "true" o "false"
        int nota = Integer.parseInt(request.getParameter("nota"));


        // Convertir ganancia a float
        float gananciaFloat = Float.parseFloat(ganancia);

        // Convertir expectativa a booleano
        boolean expectativa = Boolean.parseBoolean(expectativaString);

        // Crear un objeto Opinion con los datos
        Opinion opinion = new Opinion();
        opinion.setIdUser(userId);
        opinion.setHoraDeCierreString(horadecierre);
        opinion.setOpinionContenido(descripcion);
        opinion.setNota(nota);
        opinion.setGanancia(gananciaFloat);
        opinion.setExpectativa(expectativa);  // Establecer la expectativa

        // Establecer la conexión con la base de datos
        Database database = new Database();
        try {
            database.connect();
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        OpinionDao opinionDao = new OpinionDao(database.getConnection());

        // Recuperar el valor de modoEdicion (indica si es una edición o una nueva creación)
        String modoEdicion = request.getParameter("modoEdicion");
        boolean isEdit = "true".equals(modoEdicion);  // Si es "true", estamos editando



        boolean success = false;
        if (isEdit) {
            // Si estamos en modo edición, realizamos un update
            success = opinionDao.updateOpinion(opinion);  // Actualizar opinión
        } else {
            // Si no, estamos en creación, realizamos un insert
            success = opinionDao.insertOpinion(opinion);  // Insertar nueva opinión
        }

        if (success) {
           response.sendRedirect("graciasopinion.jsp");

        } else {
            String textoError = java.net.URLEncoder.encode("Error al guardar la opinión", "UTF-8");
            response.sendRedirect("errorgeneral.jsp?errorMessage=" + textoError);
        }

    }


    // Método doGet para manejar la eliminación de la opinión
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String horaDeCierreString = request.getParameter("horaDeCierreString");

            // Crear una instancia del DAO
            Database database = new Database();
            try {
                database.connect();
            } catch (ClassNotFoundException | SQLException e) {
                e.printStackTrace();
            }

            OpinionDao opinionDao = new OpinionDao(database.getConnection());


            // Eliminar la opinión
            boolean success = opinionDao.deleteOpinion(userId, horaDeCierreString);


            if (success) {
                response.sendRedirect("listaopiniones.jsp?eliminado=ok");
            } else {
                String textoError = java.net.URLEncoder.encode("Error al eliminar la opinión", "UTF-8");
                response.sendRedirect("errorgeneral.jsp?errorMessage=" + textoError);

            }
        }
    }

}
