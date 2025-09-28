package com.natalia.nataweb.servlet;

import com.natalia.nataweb.dao.UserDao;
import com.natalia.nataweb.database.Database;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.awt.*;
import java.io.IOException;
import java.sql.SQLException;




@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Si alguien intenta acceder al servlet con GET, redirigimos a la página principal
        response.sendRedirect("/nataweb");
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Database database = new Database();
            database.connect();
            UserDao userDao = new UserDao(database.getConnection());
            boolean userExists = userDao.loginUser(username, password);
            if (!userExists) {
                response.getWriter().println("El usuario o el password son incorrectos");
                return;
            }

            // Verificar si la cuenta está activa
            boolean isActive = userDao.isAccountActive(username);
            if (!isActive) {
                response.getWriter().println("La cuenta está desactivada. Contacte con el administrador.");
                return;
            }

            // Obtengo el rol del usuario
            String role = userDao.getUserRole(username);
            // Obtener el saldo del usuario
            float saldo = userDao.getUserSaldo(username);
            int id = userDao.getUserid(username);

            // Crea por primera vez la variable session
            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("role", role);
            session.setAttribute("saldo", saldo);
            session.setAttribute("id", id);


            response.getWriter().print("ok");


        } catch (SQLException sqle) {
            sqle.printStackTrace();
        } catch (ClassNotFoundException cnfe) {
            cnfe.printStackTrace();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
    }
}