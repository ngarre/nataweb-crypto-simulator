package com.natalia.nataweb.servlet;

import com.natalia.nataweb.dao.TareaDao;
import com.natalia.nataweb.database.Database;
import com.natalia.nataweb.model.Tarea;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/tareas")
public class TareasServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String descripcion = request.getParameter("descripcion");
        String duracionStr = request.getParameter("duracionHoras");
        String costeStr = request.getParameter("costeEuros");
        String terminadoStr = request.getParameter("terminado");

        int duracionHoras = Integer.parseInt(duracionStr);
        float costeEuros = Float.parseFloat(costeStr);
        boolean terminado = "true".equalsIgnoreCase(terminadoStr);

        String idParam = request.getParameter("id");
        int id = (idParam != null && !idParam.isEmpty()) ? Integer.parseInt(idParam) : 0;

        Tarea tarea = new Tarea();
        tarea.setId(id);
        tarea.setDescripcion(descripcion);
        tarea.setDuracionHoras(duracionHoras);
        tarea.setCosteEuros(costeEuros);
        tarea.setTerminado(terminado);

        try {
            Database database = new Database();
            database.connect();
            TareaDao tareaDao = new TareaDao(database.getConnection());

            if (id > 0) {
                tareaDao.update(tarea);
            } else {
                tareaDao.insert(tarea);
            }

            // Redirigir a la lista de tareas tras insertar o actualizar
            response.sendRedirect("listatareas.jsp");

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("errorgeneral.jsp?errorMessage=Error+en+la+operación");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);

                Database database = new Database();
                database.connect();
                TareaDao tareaDao = new TareaDao(database.getConnection());

                boolean eliminado = tareaDao.delete(id);

                // Redirige a listatareas.jsp con mensaje si fue eliminado
                if (eliminado) {
                    response.sendRedirect("listatareas.jsp?eliminado=ok");
                } else {
                    response.sendRedirect("listatareas.jsp?eliminado=fallo");
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("errorgeneral.jsp?errorMessage=Error+al+eliminar+la+tarea");
            }
        } else {
            response.sendRedirect("listatareas.jsp?error=ID+no+válido");
        }
    }
}
