package com.natalia.nataweb.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;


public class DateUtils
{
    private final static String DATE_PATTERN = "dd/MM/yyyy";
    private final static String DATETIME_PATTERN = "dd/MM/yy HH:mm:ss";  // Patrón con hora, minuto y segundo

    // Método para formatear solo la fecha
    /*
          ***********
          LA DE SANTI
          ***********
     */
    public static String format(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_PATTERN);
        return sdf.format(date);
    }



    /*
           *********************************************
           ADEMÁS DE LA SE SANTI OTRAS ADAPTACIONES MÍAS
           *********************************************
     */


    // Método para formatear la fecha con hora, minuto y segundo
    // Es así porque recibo como parámetro una fecha en formato String
    //
    // ... línea 16 de resultadoinversion.jsp
    //
    /*
           Recibo cosas como "2025-04-27 10:20:30"
           y las muestro como "27/04/25 10:20:30"
           que sea más ilustrativo para el usuario
           TAMBIÉN ESTE ES EL METODO SANTI AMPLIADO A HORA, NO SOLO A FECHA
    */
    public static String formatDateTime(String elStamp) throws ParseException {
        // Define el formato original del string
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        // Convierte el string a un objeto Date (de tipo java.util.Date)
        Date date = originalFormat.parse(elStamp);

        // Formatea la fecha en el nuevo formato y lo retorna
        SimpleDateFormat sdf = new SimpleDateFormat(DATETIME_PATTERN);
        return sdf.format(date);
    }



    // tengo que añadir este otro método a lo de Santi para no verme sujeta a convertir a Strings
    // desde JSP.  Voy creando a demanda según necesidades.  Esto lo necesito en misinversiones.jsp
    // Es así porque recibo como parámetro una fecha LocalDateTime y no un String que contiene la fecha
    /*

         Este método es como el anterior pero recibo no un String sino directamente una fecha
         que sacaré directamente de campos DateTime de la base de datos.
         la intención es la misma: mostrar resultados del tipo "27/04/25 10:20:30"

         lo uso en páginas jsp, en los scriptles que muestran fechas

    */

    public static String formatDateTime2(LocalDateTime localDateTime) {
        Date date = Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
        SimpleDateFormat sdf = new SimpleDateFormat(DATETIME_PATTERN);
        return sdf.format(date);
    }
}
