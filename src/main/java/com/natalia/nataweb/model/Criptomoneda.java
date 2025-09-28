package com.natalia.nataweb.model;

import lombok.Data;

import java.io.InputStream;
import java.time.LocalDateTime;

@Data
public class Criptomoneda
{
    // El modelo de la criptomoneda
    // Esta es la clase que va a mapear el registro de la base de datos.

    private int id;
    private String nombre;
    private String descripcion;
    private float precio;
    private LocalDateTime horaDeCorte;
    private String procedencia;
    private String riesgo;
    private String rentabilidad;
    private InputStream imagenFoto;   // tipo de atributo/campo para cargar imágenes
    private Boolean habilitada;

}
