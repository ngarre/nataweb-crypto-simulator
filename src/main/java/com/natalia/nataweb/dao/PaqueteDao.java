package com.natalia.nataweb.dao;

import com.natalia.nataweb.model.Paquete;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PaqueteDao {

    private Connection connection;

    public PaqueteDao(Connection connection) {
        this.connection = connection;
    }

    // Método para eliminar los paquetes relacionados
    public boolean deleteByUserIdAndHoraDeCierre(int idUser, Timestamp horaDeCierre) throws SQLException {
        String query = "DELETE FROM paquetes WHERE idUser = ? AND horaDeCierre = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, idUser);
            statement.setTimestamp(2, horaDeCierre);
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;  // Si se eliminó al menos una fila, devolver true
        }
    }

    public boolean deleteAllByUserId(int idUser) throws SQLException {
        String query = "DELETE FROM paquetes WHERE idUser = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, idUser);
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        }
    }

    // Inserta un registro en la tabla de paquetes
    public boolean insertPaquete(Paquete paquete) {
        String query = "INSERT INTO paquetes (horaDeCierre, idUser, username, idCripto, nombreMoneda, cantidadComprada, precioCompra, totalCompra, PrecioVenta, TotalVenta, Ganancia) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setTimestamp(1, Timestamp.valueOf(paquete.getHoraDeCierre()));  // Convertimos LocalDateTime a Timestamp
            preparedStatement.setInt(2, paquete.getIdUser());
            preparedStatement.setString(3, paquete.getUsername());
            preparedStatement.setInt(4, paquete.getIdCripto());
            preparedStatement.setString(5, paquete.getNombreMoneda());
            preparedStatement.setInt(6, paquete.getCantidadComprada());
            preparedStatement.setFloat(7, paquete.getPrecioCompra());
            preparedStatement.setFloat(8, paquete.getTotalCompra());
            preparedStatement.setFloat(9, paquete.getPrecioVenta());
            preparedStatement.setFloat(10, paquete.getTotalVenta());
            preparedStatement.setFloat(11, paquete.getGanancia());

            // Ejecutar la actualización
            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se insertó al menos una fila, se devuelve true
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    //  se le llama desde el botón VER en misinversiones.jsp
    public List<Paquete> getAllByUserIdAndHora(int userId, LocalDateTime horaDeCierre) throws SQLException {
        String query = "SELECT * FROM paquetes WHERE idUser = ? AND horaDeCierre = ?";
        PreparedStatement statement = connection.prepareStatement(query);
        statement.setInt(1, userId);
        statement.setTimestamp(2, Timestamp.valueOf(horaDeCierre));
        ResultSet resultSet = statement.executeQuery();

        List<Paquete> paquetes = new ArrayList<>();
        while (resultSet.next()) {
            Paquete paquete = new Paquete();
            paquete.setId(resultSet.getInt("id"));
            paquete.setHoraDeCierre(resultSet.getTimestamp("horaDeCierre").toLocalDateTime());
            paquete.setIdUser(resultSet.getInt("idUser"));
            paquete.setUsername(resultSet.getString("username"));
            paquete.setIdCripto(resultSet.getInt("idCripto"));
            paquete.setNombreMoneda(resultSet.getString("nombreMoneda"));
            paquete.setCantidadComprada(resultSet.getInt("cantidadComprada"));
            paquete.setPrecioCompra(resultSet.getFloat("precioCompra"));
            paquete.setTotalCompra(resultSet.getFloat("totalCompra"));
            paquete.setPrecioVenta(resultSet.getFloat("precioVenta"));
            paquete.setTotalVenta(resultSet.getFloat("totalVenta"));
            paquete.setGanancia(resultSet.getFloat("ganancia"));
            paquetes.add(paquete);
        }

        return paquetes;
    }





}
