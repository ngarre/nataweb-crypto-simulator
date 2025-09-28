package com.natalia.nataweb.dao;

import com.natalia.nataweb.model.Opinion;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;

public class OpinionDao {

    private Connection connection;

    public OpinionDao(Connection connection) {
        this.connection = connection;
    }

    public ArrayList<Opinion> buscarPorFiltros(int userId, Integer notaDesde, Integer notaHasta, Boolean expectativa) throws SQLException {
        ArrayList<Opinion> lista = new ArrayList<>();

        String sql = "SELECT * FROM opiniones WHERE idUser = ?";
        if (notaDesde != null) sql += " AND nota >= ?";
        if (notaHasta != null) sql += " AND nota <= ?";
        if (expectativa != null) sql += " AND expectativa = ?";

        PreparedStatement ps = connection.prepareStatement(sql);
        int index = 1;
        ps.setInt(index++, userId);
        if (notaDesde != null) ps.setInt(index++, notaDesde);
        if (notaHasta != null) ps.setInt(index++, notaHasta);
        if (expectativa != null) ps.setBoolean(index++, expectativa);

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Opinion op = new Opinion();
            op.setId(rs.getInt("id"));
            op.setIdUser(rs.getInt("idUser"));
            op.setHoraDeCierreString(rs.getString("HoraDeCierreString"));
            op.setOpinionContenido(rs.getString("OpinionContenido"));
            op.setNota(rs.getInt("Nota"));
            op.setExpectativa(rs.getBoolean("Expectativa"));
            op.setGanancia(rs.getFloat("Ganancia"));

            Timestamp ts = rs.getTimestamp("UltimoAcceso");
            if (ts != null) {
                op.setUltimoAcceso(ts.toLocalDateTime());
            }

            lista.add(op);
        }

        ps.close();
        return lista;
    }

    public boolean insertOpinion(Opinion opinion) {
        String query = "INSERT INTO opiniones (idUser, HoraDeCierreString, OpinionContenido, Nota, Ganancia, Expectativa, UltimoAcceso) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setInt(1, opinion.getIdUser());
            preparedStatement.setString(2, opinion.getHoraDeCierreString());
            preparedStatement.setString(3, opinion.getOpinionContenido());
            preparedStatement.setInt(4, opinion.getNota());
            preparedStatement.setFloat(5, opinion.getGanancia());
            preparedStatement.setBoolean(6, opinion.isExpectativa());
            preparedStatement.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now())); // ahora

            int rowsAffected = preparedStatement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public ArrayList<Opinion> getAllByUserId(int idUser) {
        ArrayList<Opinion> listaOpiniones = new ArrayList<>();
        String query = "SELECT * FROM opiniones WHERE idUser = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setInt(1, idUser);
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                Opinion opinion = new Opinion();
                opinion.setId(rs.getInt("id"));
                opinion.setIdUser(rs.getInt("idUser"));
                opinion.setHoraDeCierreString(rs.getString("HoraDeCierreString"));
                opinion.setOpinionContenido(rs.getString("OpinionContenido"));
                opinion.setNota(rs.getInt("Nota"));
                opinion.setGanancia(rs.getFloat("Ganancia"));
                opinion.setExpectativa(rs.getBoolean("Expectativa"));

                Timestamp ts = rs.getTimestamp("UltimoAcceso");
                if (ts != null) {
                    opinion.setUltimoAcceso(ts.toLocalDateTime());
                }

                listaOpiniones.add(opinion);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return listaOpiniones;
    }

    public boolean updateOpinion(Opinion opinion) {
        String sql = "UPDATE opiniones SET OpinionContenido = ?, Nota = ?, Expectativa = ?, UltimoAcceso = ? " +
                "WHERE idUser = ? AND HoraDeCierreString = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, opinion.getOpinionContenido());
            preparedStatement.setInt(2, opinion.getNota());
            preparedStatement.setBoolean(3, opinion.isExpectativa());
            preparedStatement.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now())); // actualizar fecha
            preparedStatement.setInt(5, opinion.getIdUser());
            preparedStatement.setString(6, opinion.getHoraDeCierreString());

            int filas = preparedStatement.executeUpdate();
            return filas > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Opinion getByUserIdAndHoraDeCierreString(int userId, String horaDeCierreString) {
        String query = "SELECT * FROM opiniones WHERE idUser = ? AND HoraDeCierreString = ?";
        Opinion opinion = null;

        try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setInt(1, userId);
            preparedStatement.setString(2, horaDeCierreString);
            ResultSet rs = preparedStatement.executeQuery();

            if (rs.next()) {
                opinion = new Opinion();
                opinion.setId(rs.getInt("id"));
                opinion.setIdUser(rs.getInt("idUser"));
                opinion.setHoraDeCierreString(rs.getString("HoraDeCierreString"));
                opinion.setOpinionContenido(rs.getString("OpinionContenido"));
                opinion.setNota(rs.getInt("Nota"));
                opinion.setGanancia(rs.getFloat("Ganancia"));
                opinion.setExpectativa(rs.getBoolean("Expectativa"));

                Timestamp ts = rs.getTimestamp("UltimoAcceso");
                if (ts != null) {
                    opinion.setUltimoAcceso(ts.toLocalDateTime());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return opinion;
    }

    public boolean deleteOpinion(int userId, String horaDeCierreString) {
        String sql = "DELETE FROM opiniones WHERE idUser = ? AND HoraDeCierreString = ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, userId);
            preparedStatement.setString(2, horaDeCierreString);

            int filas = preparedStatement.executeUpdate();
            return filas > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
