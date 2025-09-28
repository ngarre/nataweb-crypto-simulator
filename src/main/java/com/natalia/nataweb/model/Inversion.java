package com.natalia.nataweb.model;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Inversion {

    private int id;
    private LocalDateTime horaDeCierre;
    private int idUsuario;
    private String username;
    private float saldoInicial;
    private float saldoFinal;
    private float ganancia;
    private boolean gananciaBool;
}
