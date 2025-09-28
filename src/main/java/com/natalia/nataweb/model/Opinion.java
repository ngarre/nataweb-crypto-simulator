package com.natalia.nataweb.model;

import lombok.Data;

import java.time.LocalDateTime;


@Data
public class Opinion {
    private int id;
    private int idUser;
    private LocalDateTime ultimoAcceso;
    private String horaDeCierreString;
    private String opinionContenido;
    private int nota;
    private boolean expectativa;
    private float ganancia;
}