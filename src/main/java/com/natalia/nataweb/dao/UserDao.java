package com.natalia.nataweb.dao;

import com.natalia.nataweb.exception.ClienteNoEncontradoException;
import com.natalia.nataweb.model.User;

import java.sql.*;
import java.util.ArrayList;

public class UserDao {

    private Connection connection;

    public UserDao(Connection connection) {
        this.connection= connection;
    }

    // se llama desde gestionclientes.jsp para hacer las búquedas
    public ArrayList<User> buscarPorNombreYApellidos(String nombre, String apellidos) throws SQLException {
        ArrayList<User> users = new ArrayList<>();

        String sql = "SELECT * FROM users WHERE 1=1";   // Permite luego encadenar los AND sin errores de sintaxis.
                                                        //Se emplea cuando empiezas la consulta sin saber si luego vas a poner filtros o no.
        ArrayList<Object> params = new ArrayList<>();

        if (nombre != null && !nombre.trim().isEmpty()) {
            sql += " AND Nombre LIKE ?";
            params.add("%" + nombre.trim() + "%");
        }

        if (apellidos != null && !apellidos.trim().isEmpty()) {
            sql += " AND Apellidos LIKE ?";
            params.add("%" + apellidos.trim() + "%");
        }

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setNombre(rs.getString("Nombre"));
                user.setApellidos(rs.getString("Apellidos"));
                user.setCiudad(rs.getString("Ciudad"));
                user.setSaldo(rs.getFloat("Saldo"));
                user.setEdad(rs.getInt("Edad"));
                user.setCuentaActiva(rs.getBoolean("cuentaActiva"));
                user.setFechaAlta(rs.getDate("FechaAlta"));

                users.add(user);
            }
        }

        return users;
    }

    // borro usuario por su id
    public boolean deleteUserById(int id) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, id);  // Establecemos el id del usuario para eliminar
            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se eliminó al menos una fila, devolvemos true
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Método para actualizar el estado de la cuenta activa de un usuario
    public boolean updateAccountStatus(String username, boolean cuentaActiva) throws SQLException {
        String sql = "UPDATE users SET cuentaActiva = ? WHERE username = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setBoolean(1, cuentaActiva);  // Establecer el nuevo valor para cuentaActiva
            preparedStatement.setString(2, username);       // Establecer el nombre de usuario

            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se actualizó al menos una fila, se devuelve true
        } catch (SQLException e) {
            e.printStackTrace();
            return false;  // Si ocurre un error, retornamos false
        }
    }

    // Método para verificar si la cuenta del usuario está activa (Se usa en LoginServlet)
    public boolean isAccountActive(String username) throws SQLException {
        String sql = "SELECT cuentaActiva FROM users WHERE username = ?";

        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setString(1, username);

        ResultSet result = statement.executeQuery();

        // Si el usuario existe y la cuenta está activa, devuelve true
        if (result.next()) {
            return result.getBoolean("cuentaActiva");
        }
        return false;  // Si no se encuentra el usuario o la cuenta no está activa
    }


    // Método para buscar un usuario en la base de datos
    // Código de las clases de SANTI
    public boolean loginUser(String username, String password) throws SQLException {
        String sql = "select id from users where username=? and password= SHA(?)";

        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setString(1,username);
        statement.setString(2,password);

        ResultSet result = statement.executeQuery();
        if(!result.next()) {
            return false;
        }
        return true;
    }

    // Método para obtener los datos de un cliente
    public User get(String username) throws ClienteNoEncontradoException, SQLException
    {
        String sql = "SELECT * FROM users WHERE username = ?";
        PreparedStatement statement = null;
        ResultSet result = null;
        statement = connection.prepareStatement(sql);
        statement.setString(1,username);
        result = statement.executeQuery();

        if (!result.next())
        {
            return null;
        }

        User usuario = new User();
        usuario.setId(result.getInt("id"));
        usuario.setUsername(result.getString("username"));
        usuario.setEmail(result.getString("email"));
        usuario.setRole("user");
        usuario.setNombre(result.getString("Nombre"));
        usuario.setApellidos(result.getString("Apellidos"));
        // la contraseña la pongo en blanco, nula, que la vuelva a crear.
        usuario.setPassword("");
        usuario.setCiudad(result.getString("Ciudad"));
        usuario.setSaldo(result.getFloat("Saldo"));
        usuario.setEdad(result.getInt("Edad"));
        usuario.setFechaAlta(result.getDate("FechaAlta"));
        usuario.setCuentaActiva(result.getBoolean("cuentaActiva"));

        statement.close();
        return usuario;
    }

    // Método para obtener todos los usuarios
    public ArrayList<User> getAll() throws SQLException {
        ArrayList<User> users = new ArrayList<>();  // Lista para almacenar los usuarios

        String sql = "SELECT * FROM users";  // Consulta para obtener todos los usuarios
        PreparedStatement statement = connection.prepareStatement(sql);
        ResultSet result = statement.executeQuery();  // Ejecutar la consulta

        while (result.next()) {  // Mientras haya resultados
            User user = new User();
            user.setId(result.getInt("id"));
            user.setUsername(result.getString("username"));
            user.setEmail(result.getString("email"));
            user.setRole(result.getString("role"));
            user.setNombre(result.getString("Nombre"));
            user.setApellidos(result.getString("Apellidos"));
            user.setCiudad(result.getString("Ciudad"));
            user.setSaldo(result.getFloat("Saldo"));
            user.setEdad(result.getInt("Edad"));
            user.setCuentaActiva(result.getBoolean("cuentaActiva"));
            user.setFechaAlta(result.getDate("FechaAlta"));

            users.add(user);
        }

        statement.close();  // Cerrar la declaración
        return users;  // Retornar la lista de usuarios
    }


    // Método para obtener el rol de un usuario
    public String getUserRole(String username) throws SQLException {
        String sql = "SELECT role FROM users WHERE username=?";

        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setString(1, username);

        ResultSet result = statement.executeQuery();

        // Si el usuario existe, devuelve el rol, si no devuelve null
        if (result.next()) {
            return result.getString("role");
        }
        return null;  // En caso de que no se encuentre el usuario
    }

    // Método para OBTENER EL SALDO de un usuario
    public float getUserSaldo(String username) throws SQLException {
        String sql = "SELECT Saldo FROM users WHERE username = ?";

        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setString(1, username);  // Establecer el nombre de usuario como parámetro

        ResultSet result = statement.executeQuery();

        if (result.next()) {
            return result.getFloat("Saldo");  // Recupera el saldo del usuario
        } else {
            // Si el usuario no existe.
            throw new SQLException("Usuario no encontrado");
        }
    }

    // Método para ACTUALIZAR EL SALDO de un usuario
    // *********************************************
    public void updateUserSaldo(String username, float nuevoSaldo) throws SQLException {
        String sql = "UPDATE users SET Saldo = ? WHERE username = ?";

        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setFloat(1, nuevoSaldo);  // Establecer el nuevo saldo
        statement.setString(2, username);  // Establecer el nombre de usuario

        int filasAfectadas = statement.executeUpdate();

        if (filasAfectadas == 0) {
            // Si no se actualizó ningún registro, significa que no se encontró al usuario.
            throw new SQLException("Usuario no encontrado o no se pudo actualizar el saldo");
        }
    }

    // recupero id de la tabla de usuarios
    // ***********************************
    public int getUserid(String username) throws SQLException {
        String sql = "SELECT id FROM users WHERE username=?";

        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setString(1, username);

        ResultSet result = statement.executeQuery();

        if (result.next()) {
            return result.getInt("id"); // Cambia "your_int_field" por el nombre real de la columna
        }
        return -1;
    }


    // Método para insertar un nuevo usuario en la base de datos
    // *********************************************************
    public boolean insertUser(User user) {
        String query = "INSERT INTO users (username, password, email, role, Nombre, Apellidos, Ciudad, Saldo, edad) VALUES (?, SHA(?), ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setString(1, user.getUsername());  // nickname
            preparedStatement.setString(2, user.getPassword());
            preparedStatement.setString(3, user.getEmail());    // email (supongamos que lo que envíes es el correo del usuario)
            preparedStatement.setString(4, "user");     // role, puedes asignar un valor predeterminado, como "user"
            preparedStatement.setString(5, user.getNombre());
            preparedStatement.setString(6, user.getApellidos());
            preparedStatement.setString(7, user.getCiudad());
            preparedStatement.setFloat(8, user.getSaldo());       // Saldo, puede ser 0 al momento de crear la cuenta.
            preparedStatement.setInt(9, user.getEdad());

            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se insertó al menos una fila, se devuelve true
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    // Método para actualizar los datos de un usuario existente en la base de datos
    // ****************************************************************************
    public boolean updateUser(User user) {
        String query = "UPDATE users SET password = SHA(?), email = ?, role = ?, Nombre = ?, Apellidos = ?, Ciudad = ?, Saldo = ?, edad = ? WHERE username = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            // Seteamos los parámetros para la actualización
            preparedStatement.setString(1, user.getPassword());    // Actualizamos la contraseña
            preparedStatement.setString(2, user.getEmail());       // Actualizamos el correo electrónico
            preparedStatement.setString(3, "user");                // Mantén el rol predeterminado o modifícalo si es necesario
            preparedStatement.setString(4, user.getNombre());      // Actualizamos el nombre
            preparedStatement.setString(5, user.getApellidos());   // Actualizamos los apellidos
            preparedStatement.setString(6, user.getCiudad());      // Actualizamos la ciudad
            preparedStatement.setFloat(7, user.getSaldo());          // Actualizamos el saldo
            preparedStatement.setInt(8, user.getEdad());
            preparedStatement.setString(9, user.getUsername());    // Condición para actualizar el usuario correspondiente


            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se actualizó al menos una fila, se devuelve true
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }



}





