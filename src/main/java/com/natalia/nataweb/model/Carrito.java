package com.natalia.nataweb.model;

import lombok.Data;

@Data
public class Carrito {

    // Atención porque este modelo solo es para la variable de sesión. No hay DAO

    private int idCripto;
    private int idUsuario;
    private String nombreMoneda;
    private int cantidad;
    private float precioUnitario;
    private float precioTotal;
    private float precioActualizado;  // esto se carga cuando se finaliza la inversión
                                      //es el nuevo precio de la moneda actualizado. unitario.

    // tener aquí el nombre de la moneda es superfluo ya que tengo su id
    // sin embargo para operatoria rápida de mostrar en pantalla me va a ser ágil
    // usarlo así

}
