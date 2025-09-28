package com.natalia.nataweb.servlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false); // Obtener la sesión actual sin crear una nueva
        if (session != null) {
            session.invalidate(); // Invalidar la sesión
        }
        response.sendRedirect("/nataweb"); // Redirigir al login
    }
}