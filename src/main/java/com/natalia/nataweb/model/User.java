package com.natalia.nataweb.model;
import lombok.Data;

import java.util.Date;

@Data
public class User {
    private int id;
    private String username;
    private String password;
    private String email;
    private String role;
    private String nombre;
    private String apellidos;
    private String ciudad;
    private float saldo;
    private int edad;
    private boolean cuentaActiva;
    private Date fechaAlta;
}
