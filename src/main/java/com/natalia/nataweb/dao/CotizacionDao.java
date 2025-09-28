package com.natalia.nataweb.dao;

import com.natalia.nataweb.model.Cotizacion;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;

public class CotizacionDao {

    private Connection connection;

    public CotizacionDao(Connection connection) {
        this.connection = connection;
    }

    // Inserta un registro en la tabla de cotizaciones
    public boolean insertCotizacion(Cotizacion cotizacion) {
        String query = "INSERT INTO cotizaciones (idCripto, HoraDeCorte, Precio, PorcentajeVariacion, PrecioAnterior, RecalculadoPor, ValorAlza) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setInt(1, cotizacion.getIdCripto());
            preparedStatement.setTimestamp(2, Timestamp.valueOf(cotizacion.getHoraDeCorte()));
            preparedStatement.setFloat(3, cotizacion.getPrecio());
            preparedStatement.setInt(4, cotizacion.getPorcentajeVariacion());
            preparedStatement.setFloat(5, cotizacion.getPrecioAnterior());
            preparedStatement.setString(6, cotizacion.getRecalculadoPor());
            preparedStatement.setBoolean(7, cotizacion.isValorAlza());

            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Obtener todas las cotizaciones con el nombre de la criptomoneda
    public ArrayList<Cotizacion> getAllCotizaciones() throws SQLException {
        ArrayList<Cotizacion> cotizacionesList = new ArrayList<>();

        String query = "SELECT c.id, c.idCripto, c.HoraDeCorte, c.Precio, c.PorcentajeVariacion, " +
                "c.PrecioAnterior, c.RecalculadoPor, c.ValorAlza, cr.Nombre " +
                "FROM cotizaciones c " +
                "JOIN criptomonedas cr ON c.idCripto = cr.id";

        try (PreparedStatement statement = connection.prepareStatement(query);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                Cotizacion cotizacion = new Cotizacion();
                cotizacion.setId(result.getInt("id"));
                cotizacion.setIdCripto(result.getInt("idCripto"));
                cotizacion.setHoraDeCorte(result.getTimestamp("HoraDeCorte").toLocalDateTime());
                cotizacion.setPrecio(result.getFloat("Precio"));
                cotizacion.setPorcentajeVariacion(result.getInt("PorcentajeVariacion"));
                cotizacion.setPrecioAnterior(result.getFloat("PrecioAnterior"));
                cotizacion.setRecalculadoPor(result.getString("RecalculadoPor"));
                cotizacion.setValorAlza(result.getBoolean("ValorAlza"));
                cotizacion.setNombreCripto(result.getString("Nombre"));

                cotizacionesList.add(cotizacion);
            }
        }

        return cotizacionesList;
    }

    public void borrarTodas() throws SQLException {
        String sql = "DELETE FROM cotizaciones";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.executeUpdate();
        }
    }


}
