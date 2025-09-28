package com.natalia.nataweb.model;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Paquete
{
    private int id;
    private LocalDateTime horaDeCierre;
    private int idUser;
    private String username;
    private int idCripto;
    private String nombreMoneda;
    private int cantidadComprada;
    private float precioCompra;
    private float totalCompra;
    private float precioVenta;
    private float totalVenta;
    private float ganancia;
}
