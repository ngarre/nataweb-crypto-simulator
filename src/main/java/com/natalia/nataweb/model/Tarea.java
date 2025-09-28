package com.natalia.nataweb.model;

import lombok.Data;

import java.time.LocalDateTime;


@Data
public class Tarea {
    private int id;

    private LocalDateTime fechaRegistro;
    private int duracionHoras;  // valores enteros, no se admiten fracciones de hora
    private float costeEuros;
    private String descripcion;
    private boolean terminado;

}