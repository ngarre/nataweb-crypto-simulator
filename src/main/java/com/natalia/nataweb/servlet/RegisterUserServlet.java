package com.natalia.nataweb.servlet;

import com.natalia.nataweb.dao.UserDao;
import com.natalia.nataweb.database.Database;
import com.natalia.nataweb.exception.ClienteNoEncontradoException;
import com.natalia.nataweb.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/registerUser")
public class RegisterUserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Obtener los datos del formulario
        String nickname = request.getParameter("nickname");
        String password = request.getParameter("password");
        String nombre = request.getParameter("nombre");
        String apellidos = request.getParameter("apellidos");
        String ciudad = request.getParameter("ciudad");
        float saldo = Float.parseFloat(request.getParameter("saldo"));
        String email = request.getParameter("email");
        int edad = Integer.parseInt(request.getParameter("edad"));

        // Crear el objeto User
        User user = new User();
        user.setUsername(nickname);
        user.setPassword(password);
        user.setNombre(nombre);
        user.setApellidos(apellidos);
        user.setCiudad(ciudad);
        user.setRole("user");  // Asignamos un rol por defecto
        user.setSaldo(saldo); // Saldo inicial
        user.setEmail(email);
        user.setEdad(edad);

        // Usar la clase Database para insertar el usuario
        Database database = new Database();
        try {
            database.connect();
            UserDao userDao = new UserDao(database.getConnection());

            HttpSession session = request.getSession(false); // Obtener la sesión si existe
            // el parámetro false es para que NO CREE UNA SESION AQUÍ SI NO EXISTE sesión ya.
            // sin el false crearía una sesión aquí y no procede.

            User existeUsuario = userDao.get(nickname); // Buscar usuario por nickname

            // Si existe la sesión, se está intentando actualizar un usuario
            if (session != null && session.getAttribute("username") != null) {

                // session != null                               <--- esto me asegura que hay sesión existente
                // session.getAttribute("username") != null      <--- al crearse sesión tal como he hecho la aplicación
                //                                                    se asigna ya el username. En definitiva todo ese
                //                                                    if( ) considero que es recomendable.

                // Actualización de datos del usuario
                if (existeUsuario != null) {
                    boolean successUpdate = userDao.updateUser(user);
                    if (successUpdate) {
                        session.setAttribute("saldo", saldo);  // Actualizamos el saldo en la sesión
                        response.getWriter().print("ok");  // Operación exitosa
                    } else {
                        response.getWriter().print("Fallo en la operación. Revise los datos.");
                    }
                } else {
                    response.getWriter().print("Usuario no encontrado para actualizar.");
                }
            } else {
                // Si no hay sesión, es un nuevo registro (alta de usuario)
                if (existeUsuario == null) {
                    boolean successInsert = userDao.insertUser(user);
                    if (successInsert) {
                        response.getWriter().print("ok");  // Registro exitoso
                    } else {
                        response.getWriter().print("Fallo en la operación. Revise los datos.");
                    }
                } else {
                    // Si el nickname ya existe, no permitimos el registro
                    response.getWriter().print("El nickname ya está en uso. Por favor, elija otro.");
                }
            }

        } catch (ClassNotFoundException | SQLException | ClienteNoEncontradoException e) {
            e.printStackTrace();
            response.getWriter().print("Error en la base de datos");
        } finally {
            try {
                database.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
