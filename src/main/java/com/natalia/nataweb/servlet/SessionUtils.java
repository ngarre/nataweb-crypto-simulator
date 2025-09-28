package com.natalia.nataweb.servlet;

import jakarta.servlet.http.HttpServletRequest;

public class SessionUtils
{
    // Función que verifica si la sesión está activa
    public static boolean isSessionActive(HttpServletRequest request) {
        // Obtener el atributo "username" de la sesión
        String username = (String) request.getSession().getAttribute("username");

        // Si "username" no es null o vacío, la sesión está activa
        return username != null && !username.isEmpty();
    }

}
