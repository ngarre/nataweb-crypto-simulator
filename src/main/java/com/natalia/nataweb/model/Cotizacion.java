package com.natalia.nataweb.model;

import lombok.Data;

import java.time.LocalDateTime;

@Data

public class Cotizacion {
    private int id;
    private int idCripto;
    private String nombreCripto;   // esto es para relacionar con criptomonedas. ver dao.
    private LocalDateTime horaDeCorte;
    private float precio;
    private int porcentajeVariacion;
    private float precioAnterior;
    private String recalculadoPor;
    private boolean ValorAlza;
}
