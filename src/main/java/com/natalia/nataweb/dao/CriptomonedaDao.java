package com.natalia.nataweb.dao;

import com.natalia.nataweb.exception.MonedaNoEncontradaException;
import com.natalia.nataweb.model.Cotizacion;
import com.natalia.nataweb.model.Criptomoneda;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.sql.*;
import java.util.ArrayList;


public class CriptomonedaDao
{
    private Connection connection;

    public CriptomonedaDao(Connection connection)
    {
        this.connection = connection;
    }

    // Lo llamo desde gestionmonedas.jsp (lado del administrador
    // para mí esta forma de hacer las búsquedas es más clara y más fácil de mantener que la propuesta por
    // Santi.  Me da más juego y facilidad de mantenimiento de código

    public ArrayList<Criptomoneda> buscarPorPrecioYEstado(double minPrecio, double maxPrecio, String habilitada) throws SQLException {
        ArrayList<Criptomoneda> lista = new ArrayList<>();

        String sql = "SELECT * FROM criptomonedas WHERE Precio >= ? AND Precio <= ?";
        boolean tieneEstado = habilitada != null && !habilitada.trim().isEmpty();

        if (tieneEstado) {
            sql += " AND Habilitada = ?";
        }

        PreparedStatement statement = connection.prepareStatement(sql);
        int index = 1;

        statement.setDouble(index++, minPrecio);
        statement.setDouble(index++, maxPrecio);

        if (tieneEstado) {
            boolean habilitadaBool = habilitada.equalsIgnoreCase("Sí");
            statement.setBoolean(index++, habilitadaBool);
        }

        ResultSet result = statement.executeQuery();
        while (result.next()) {
            Criptomoneda c = new Criptomoneda();
            c.setId(result.getInt("id"));
            c.setNombre(result.getString("Nombre"));
            c.setPrecio(result.getFloat("Precio"));
            c.setProcedencia(result.getString("Procedencia"));
            c.setRiesgo(result.getString("Riesgo"));
            c.setRentabilidad(result.getString("Rentabilidad"));
            c.setHabilitada(result.getBoolean("Habilitada"));

            lista.add(c);
        }

        statement.close();
        return lista;
    }


    // esta es otra búsqueda que hago pero desde el index.jsp
    // insisto en que me hago así los métodos de búsqueda porque resulta más claro que lo propuesto en clase.
    public ArrayList<Criptomoneda> buscarPorCriterios(String rentabilidad, String riesgo) throws SQLException {
        ArrayList<Criptomoneda> listaCriptomonedas = new ArrayList<>();

        String sql = "SELECT * FROM criptomonedas WHERE Habilitada = True";

        boolean tieneRentabilidad = rentabilidad != null && !rentabilidad.trim().isEmpty();
        boolean tieneRiesgo = riesgo != null && !riesgo.trim().isEmpty();

        if (tieneRentabilidad) {
            sql += " AND Rentabilidad LIKE ?";
        }

        if (tieneRiesgo) {
            sql += " AND Riesgo LIKE ?";
        }

        PreparedStatement statement = connection.prepareStatement(sql);

        int index = 1;
        if (tieneRentabilidad) {
            statement.setString(index++, "%" + rentabilidad.trim() + "%");
        }
        if (tieneRiesgo) {
            statement.setString(index++, "%" + riesgo.trim() + "%");
        }

        ResultSet result = statement.executeQuery();
        while (result.next()) {
            Criptomoneda cmoneda = new Criptomoneda();
            cmoneda.setId(result.getInt("id"));
            cmoneda.setNombre(result.getString("Nombre"));
            cmoneda.setPrecio(result.getFloat("Precio"));
            cmoneda.setProcedencia(result.getString("Procedencia"));
            cmoneda.setRiesgo(result.getString("Riesgo"));
            cmoneda.setRentabilidad(result.getString("Rentabilidad"));
            cmoneda.setHabilitada(result.getBoolean("Habilitada"));

            listaCriptomonedas.add(cmoneda);
        }

        statement.close();
        return listaCriptomonedas;
    }






    // Método para obtener una criptomoneda por su nombre (zona administrador)
    public Criptomoneda getByNombre(String nombre) throws SQLException {
        String sql = "SELECT * FROM criptomonedas WHERE Nombre = ?";
        PreparedStatement statement = null;
        ResultSet result = null;
        statement = connection.prepareStatement(sql);
        statement.setString(1, nombre);
        result = statement.executeQuery();

        if (result.next()) {
            // Si se encuentra la criptomoneda, la retornamos
            Criptomoneda cmoneda = new Criptomoneda();
            cmoneda.setId(result.getInt("id"));
            cmoneda.setNombre(result.getString("Nombre"));
            cmoneda.setDescripcion(result.getString("Descripcion"));
            cmoneda.setPrecio(result.getFloat("Precio"));
            cmoneda.setProcedencia(result.getString("Procedencia"));
            cmoneda.setRiesgo(result.getString("Riesgo"));
            cmoneda.setRentabilidad(result.getString("Rentabilidad"));
            cmoneda.setHabilitada(result.getBoolean("Habilitada"));
            cmoneda.setImagenFoto(result.getBinaryStream("ImagenFoto"));
            return cmoneda;
        } else {
            // Si no se encuentra la criptomoneda, retornamos null
            return null;
        }
    }





    // ACTUALIZO PRECIO Y HORA DE COTIZACION DE ESE PRECIO
    // ***************************************************
    public boolean updateMonedaPrecio(Criptomoneda cmoneda) throws SQLException {

        String query = "UPDATE criptomonedas SET Precio=?, HoraDeCorte=? WHERE id = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {

            preparedStatement.setFloat(1, cmoneda.getPrecio());
            preparedStatement.setTimestamp(2, Timestamp.valueOf(cmoneda.getHoraDeCorte()));
            preparedStatement.setInt(3, cmoneda.getId());

            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se insertó al menos una fila, se devuelve true
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    // Recupero todas las criptomonedas
    // ********************************
    public ArrayList<Criptomoneda> getAll(boolean soloHabilitadas) throws SQLException {

        // Si soloHabilitadas es verdadero, filtramos por Habilitada=True
        // el usuario solo verá las habilitadas.  el administrador todas.

        String sql;
        if (soloHabilitadas) {
            sql = "SELECT * FROM criptomonedas WHERE Habilitada=True";
        } else {
            sql = "SELECT * FROM criptomonedas"; // Sin filtro, recuperamos todas
        }

        PreparedStatement statement = null;
        ResultSet result = null;

        statement = connection.prepareStatement(sql);
        result = statement.executeQuery();
        ArrayList<Criptomoneda> ListaCriptomonedas = new ArrayList<>();
        while (result.next()) {
            Criptomoneda cmoneda = new Criptomoneda();
            cmoneda.setId(result.getInt("id"));
            cmoneda.setNombre(result.getString("Nombre"));
            cmoneda.setPrecio(result.getFloat("Precio"));
            cmoneda.setProcedencia(result.getString("Procedencia"));
            cmoneda.setRiesgo(result.getString("Riesgo"));
            cmoneda.setRentabilidad(result.getString("Rentabilidad"));
            cmoneda.setHabilitada(result.getBoolean("Habilitada"));

            ListaCriptomonedas.add(cmoneda);
        }
        statement.close();
        return ListaCriptomonedas;
    }


    // Recupero la información de una sola criptomoneda
    public Criptomoneda get(int id) throws SQLException
    {
        String sql = "SELECT * FROM criptomonedas WHERE id = ?";
        PreparedStatement statement = null;
        ResultSet result = null;
        statement = connection.prepareStatement(sql);
        statement.setInt(1,id);
        result = statement.executeQuery();

        if (!result.next())
        {
            //throw new MonedaNoEncontradaException();
            statement.close();
            return null;
        }

        Criptomoneda cmoneda = new Criptomoneda();
        cmoneda.setId(result.getInt("id"));
        cmoneda.setNombre(result.getString("Nombre"));
        cmoneda.setDescripcion(result.getString("Descripcion"));
        cmoneda.setPrecio(result.getFloat("Precio"));
        cmoneda.setHabilitada(result.getBoolean("Habilitada"));

        // fijarse que infomoneda.jsp también llama a este método. sin embargo el usuario, a la hora de
        // seleccionarla para la compra, si no está habilitada, no podría porque no se verá en el panel
        // principal de index.jsp


        statement.close();
        return cmoneda;
    }

    // INSERTO UNA MONEDA  (esto para el role de administrador
    // ******************
    public boolean insertMoneda(Criptomoneda cmoneda) throws SQLException {
        // SQL para insertar una nueva criptomoneda, agregando el campo habilitada
        String query = "INSERT INTO criptomonedas (Nombre, Descripcion, Precio, Procedencia, Riesgo, Rentabilidad, Habilitada, ImagenFoto) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            // Establecer los parámetros de la consulta
            preparedStatement.setString(1, cmoneda.getNombre());
            preparedStatement.setString(2, cmoneda.getDescripcion());
            preparedStatement.setFloat(3, cmoneda.getPrecio());
            preparedStatement.setString(4, cmoneda.getProcedencia());
            preparedStatement.setString(5, cmoneda.getRiesgo());
            preparedStatement.setString(6, cmoneda.getRentabilidad());
            preparedStatement.setBoolean(7, cmoneda.getHabilitada());  // Se agrega habilitada como parámetro
            preparedStatement.setBlob(8, cmoneda.getImagenFoto());

            // Ejecutar la consulta
            int rowsAffected = preparedStatement.executeUpdate();

            // Si se insertó al menos una fila, devolver true
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;  // Si ocurre un error, devolver false
        }
    }


    public boolean updateMoneda(Criptomoneda cmoneda) throws SQLException {
        StringBuilder query = new StringBuilder("UPDATE criptomonedas SET Nombre = ?, Descripcion = ?, Precio = ?, Procedencia = ?, Riesgo = ?, Rentabilidad = ?, Habilitada = ?");

        // Solo agregar la imagen si es necesario
        if (cmoneda.getImagenFoto() != null) {
            query.append(", ImagenFoto = ?");
        }

        query.append(" WHERE id = ?");

        try (PreparedStatement preparedStatement = connection.prepareStatement(query.toString())) {
            // Establecer los parámetros comunes
            preparedStatement.setString(1, cmoneda.getNombre());
            preparedStatement.setString(2, cmoneda.getDescripcion());
            preparedStatement.setFloat(3, cmoneda.getPrecio());
            preparedStatement.setString(4, cmoneda.getProcedencia());
            preparedStatement.setString(5, cmoneda.getRiesgo());
            preparedStatement.setString(6, cmoneda.getRentabilidad());
            preparedStatement.setBoolean(7, cmoneda.getHabilitada()); // Se agrega habilitada como parámetro

            // Si la imagen no es nula, añadirla como parámetro
            int paramIndex = 8; // Comienza después de Habilitada
            if (cmoneda.getImagenFoto() != null) {
                preparedStatement.setBlob(paramIndex++, cmoneda.getImagenFoto());
            }

            preparedStatement.setInt(paramIndex, cmoneda.getId());

            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteMoneda(int id) throws SQLException {
        String query = "DELETE FROM criptomonedas WHERE id = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, id);
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public InputStream getImagen(int id) throws SQLException {
        String sql = "SELECT ImagenFoto FROM criptomonedas WHERE id = ?";
        PreparedStatement statement = null;
        ResultSet result = null;
        InputStream imagenStream = null;

        try {
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            result = statement.executeQuery();

            if (result.next()) {
                imagenStream = result.getBinaryStream("ImagenFoto");  // Recupera el InputStream del campo ImagenFoto
            }
        } finally {
            if (statement != null) statement.close();
            if (result != null) result.close();
        }

        return imagenStream;
    }



}
