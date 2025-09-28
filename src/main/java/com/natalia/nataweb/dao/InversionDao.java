package com.natalia.nataweb.dao;
import com.natalia.nataweb.model.Inversion;


import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


public class InversionDao {

    private Connection connection;

    public InversionDao(Connection connection) {
        this.connection = connection;
    }

    // a este método lo llamo desde el botón eliminar de misinversiones.jsp
    public boolean deleteByUserIdAndHoraDeCierre(int idUser, String horaDeCierre) throws SQLException {
        String query = "DELETE FROM inversiones WHERE idUser = ? AND horaDeCierre = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, idUser);
            statement.setTimestamp(2, Timestamp.valueOf(horaDeCierre));
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public boolean deleteAllByUserId(int idUser) throws SQLException {
        String query = "DELETE FROM inversiones WHERE idUser = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, idUser);
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        }
    }

    // este método lo voy a usar desde misinversiones.jsp
    public List<Inversion> getAllByUserId(int userId) throws SQLException {
        String query = "SELECT * FROM inversiones WHERE idUser = ? ORDER BY horaDeCierre DESC";
        PreparedStatement statement = connection.prepareStatement(query);
        statement.setInt(1, userId);
        ResultSet resultSet = statement.executeQuery();

        List<Inversion> inversiones = new ArrayList<>();
        while (resultSet.next()) {
            Inversion inversion = new Inversion();
            inversion.setId(resultSet.getInt("id"));
            inversion.setHoraDeCierre(resultSet.getTimestamp("horaDeCierre").toLocalDateTime());
            inversion.setIdUsuario(resultSet.getInt("idUser"));
            inversion.setUsername(resultSet.getString("username"));
            inversion.setSaldoInicial(resultSet.getFloat("saldoInicial"));
            inversion.setSaldoFinal(resultSet.getFloat("saldoFinal"));
            inversion.setGanancia(resultSet.getFloat("Ganancia"));
            inversion.setGananciaBool(resultSet.getBoolean("GananciaBool"));
            inversiones.add(inversion);
        }

        return inversiones;
    }


    // Inserta un registro en la tabla de inversiones
    public boolean insertInversion(Inversion inversion)  {
        String query = "INSERT INTO inversiones (horaDeCierre, idUser, username, saldoInicial, saldoFinal, Ganancia, GananciaBool) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setTimestamp(1, Timestamp.valueOf(inversion.getHoraDeCierre()));
            preparedStatement.setInt(2, inversion.getIdUsuario());
            preparedStatement.setString(3, inversion.getUsername());
            preparedStatement.setFloat(4, inversion.getSaldoInicial());
            preparedStatement.setFloat(5, inversion.getSaldoFinal());
            preparedStatement.setFloat(6, inversion.getGanancia());
            preparedStatement.setBoolean(7, inversion.isGananciaBool());

            // Ejecutar la actualización
            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;  // Si se insertó al menos una fila, se devuelve true

        } catch (SQLException e) {

            e.printStackTrace();
            return false;
        }
    }


    public Inversion get(String horaDeCierre) throws SQLException {

        String query = "SELECT * FROM inversiones WHERE horaDeCierre = ?";

        PreparedStatement statement = null;
        ResultSet result = null;
        statement = connection.prepareStatement(query);
        statement.setTimestamp(1, Timestamp.valueOf(horaDeCierre));
        result = statement.executeQuery();

        if (!result.next())
        {
            return null;
        }

        Inversion inversion = new Inversion();
        inversion.setHoraDeCierre(result.getTimestamp("horaDeCierre").toLocalDateTime());
        inversion.setIdUsuario(result.getInt("idUser"));
        inversion.setUsername(result.getString("username"));
        inversion.setSaldoInicial(result.getFloat("saldoInicial"));
        inversion.setSaldoFinal(result.getFloat("saldoFinal"));
        inversion.setGanancia(result.getFloat("Ganancia"));
        inversion.setGananciaBool(result.getBoolean("GananciaBool"));

        statement.close();
        return inversion;
    }

}
