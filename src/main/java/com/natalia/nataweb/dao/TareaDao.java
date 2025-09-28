package com.natalia.nataweb.dao;


import com.natalia.nataweb.model.Tarea;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;

public class TareaDao {

    private Connection connection;

    public TareaDao(Connection connection) {
        this.connection = connection;
    }


    public ArrayList<Tarea> getAll() throws SQLException {

        String sql;
        sql = "SELECT * FROM tareas";

        PreparedStatement statement = null;
        ResultSet result = null;

        statement = connection.prepareStatement(sql);
        result = statement.executeQuery();
        ArrayList<Tarea> listaTareas = new ArrayList<>();
        while (result.next()) {
            Tarea tarea = new Tarea();
            tarea.setId(result.getInt("id"));
            // Recuperar el campo de fecha

            Timestamp timestamp = result.getTimestamp("fecha");
            if (timestamp != null) {
                tarea.setFechaRegistro(timestamp.toLocalDateTime());
            }

            tarea.setDuracionHoras(result.getInt("DuracionHoras"));
            tarea.setDescripcion(result.getString("Descripcion"));
            tarea.setCosteEuros(result.getFloat("CosteEuros"));
            tarea.setTerminado(result.getBoolean("Terminado"));

            listaTareas.add(tarea);
        }
        statement.close();
        return listaTareas;
    }

    public Tarea get(int id) throws SQLException {
        String sql = "SELECT * FROM tareas WHERE id = ?";
        Tarea tarea = null;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    tarea = new Tarea();
                    tarea.setId(result.getInt("id"));

                    Timestamp timestamp = result.getTimestamp("fecha");
                    if (timestamp != null) {
                        tarea.setFechaRegistro(timestamp.toLocalDateTime());
                    }

                    tarea.setDuracionHoras(result.getInt("DuracionHoras"));
                    tarea.setCosteEuros(result.getFloat("CosteEuros"));
                    tarea.setDescripcion(result.getString("Descripcion"));
                    tarea.setTerminado(result.getBoolean("Terminado"));
                }
            }
        }

        return tarea;
    }

    public void insert(Tarea tarea) throws SQLException {
        String sql = "INSERT INTO tareas (fecha, DuracionHoras, CosteEuros, Descripcion, Terminado) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now())); // Fecha actual
            statement.setInt(2, tarea.getDuracionHoras());
            statement.setFloat(3, tarea.getCosteEuros());
            statement.setString(4, tarea.getDescripcion());
            statement.setBoolean(5, tarea.isTerminado());

            statement.executeUpdate();
        }
    }

    public void update(Tarea tarea) throws SQLException {
        String sql = "UPDATE tareas SET DuracionHoras = ?, CosteEuros = ?, Descripcion = ?, Terminado = ? WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, tarea.getDuracionHoras());
            statement.setFloat(2, tarea.getCosteEuros());
            statement.setString(3, tarea.getDescripcion());
            statement.setBoolean(4, tarea.isTerminado());
            statement.setInt(5, tarea.getId());

            statement.executeUpdate();
        }
    }

    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM tareas WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            int filasAfectadas = statement.executeUpdate();
            return filasAfectadas > 0;
        }
    }

}

