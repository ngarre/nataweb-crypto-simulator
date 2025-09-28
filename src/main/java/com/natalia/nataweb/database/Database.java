package com.natalia.nataweb.database;

import lombok.Getter;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class Database
{


    @Getter
    private Connection connection;   // Esta es la variable que realmente nos interesa.  La conexión devuelta.

    public void connect() throws ClassNotFoundException, SQLException {
        Class.forName("org.mariadb.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mariadb://localhost:3306/nataweb", "root", "bbdd2024nata");
    }

    public void close() throws SQLException {
        connection.close();
    }

}
