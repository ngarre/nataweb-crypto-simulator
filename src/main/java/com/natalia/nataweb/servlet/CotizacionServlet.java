package com.natalia.nataweb.servlet;


import com.natalia.nataweb.dao.*;
import com.natalia.nataweb.database.Database;
import com.natalia.nataweb.model.*;
import jakarta.servlet.annotation.WebServlet;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Random;


@WebServlet("/actualizaCotizacion")
public class CotizacionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Aquí guardo el instante preciso en el que accedo a este Servlet.
        // voy a cumplimentar probablemente varias tablas y este dato debe de ser común a todas ellas.
        LocalDateTime momentoDeCorte = LocalDateTime.now();

        // en el parámetro modo puede venir la palabra "terminar" para indicar que el usuario/cliente está
        // terminando la inversión.  Si no la está terminando este servlet solo actualiza la tabla de
        // cotizaciones y el precio de la criptomononeda y abandona.
        // Si modo = "terminar" se harán más cosas, insertar inversión y paquetes.
        String modo = request.getParameter("modo");

        Database database = new Database();
        try {
            database.connect();
            // Ahora tengo que leer la tabla criptomonedas
            CriptomonedaDao criptomonedaDao = new CriptomonedaDao(database.getConnection());

            // refresco el valor de cotización de todas las monedas aunque no estén habilitadas
            // Recordar que habilitadas o no lo establece el administrador.  sirve para que dejen de estar
            // accesibles a la compra, que no aparezcan en index.jsp.  Pero su precio si que
            // lo actualizo en la tabla.
            List<Criptomoneda> listaCriptomonedas = criptomonedaDao.getAll(false);


            // Obtengo la lista del carrito en sesión
            HttpSession session = request.getSession();
            List<Carrito> listaCarritos = (List<Carrito>) session.getAttribute("carritos");

            // PRIMERO agrego nuevas cotizaciones y actualizo precios de las monedas
            for (Criptomoneda cmoneda : listaCriptomonedas) {
                Cotizacion cotizacion = new Cotizacion();

                cotizacion.setIdCripto(cmoneda.getId());
                cotizacion.setHoraDeCorte(momentoDeCorte);

                float precioAnterior = cmoneda.getPrecio();
                cotizacion.setPrecioAnterior(precioAnterior);

                // el porcentaje de incremento o decremento lo cálculo en el método Aleatorio()
                int porcentaje = Aleatorio();
                // aquí el precio lo cambio según el porcentaje
                float nuevoPrecio = precioAnterior + (precioAnterior * porcentaje / 100);
                if (nuevoPrecio < 1)
                    // valor mínimo porque me apetece hacerlo así.
                    nuevoPrecio = 7.75F;

                // Lo que hago ahí arriba es aplicar un incremento o decremento porcentual que me invento.
                // ver el método Aleatorio().  Si el valor resultante, precio resultante, cae por debajo de 1
                // lo repongo a 7,75

                cotizacion.setPrecio(nuevoPrecio);
                cotizacion.setPorcentajeVariacion(porcentaje);

                // Calculo ValorAlza
                boolean valorAlza = nuevoPrecio > precioAnterior;
                cotizacion.setValorAlza(valorAlza);

                // Obtengo quién recalculó (username o guest)
                String recalculadoPor = "guest";
                if (session != null && session.getAttribute("username") != null) {
                    recalculadoPor = (String) session.getAttribute("username");
                }
                cotizacion.setRecalculadoPor(recalculadoPor);



                CotizacionDao cotizacionDao = new CotizacionDao(database.getConnection());

                // [COTIZACIONES] ---> Inserto nueva cotización para la moneda
                // es aquí donde se van a crear nuevos registros para todas la monedas con el nuevo precio
                boolean success = cotizacionDao.insertCotizacion(cotizacion);


                // [CRIPTOMONEDAS] ---> Aquì actualizo en concreto el precio de esa moneda en su tabla matriz
                // Actualizo la tabla de criptomonedas.  A cada una le actualizo el precio

                // Por cierto creo otra instancia de CriptomonedaDao llamada criptomonedaDao2 porque
                // necesito otra para los updates.  No puedo cerrar la anterior si no es concluyendo
                // el servlet o cerrando la conexión a la base de datos.
                CriptomonedaDao criptomonedaDao2 = new CriptomonedaDao(database.getConnection());
                // Actualizar el registro de la tabla criptomonedas
                cmoneda.setPrecio(nuevoPrecio);
                cmoneda.setHoraDeCorte(momentoDeCorte);

                // [CRIPTOMONEDAS] ---> Actualizo precio de la moneda
                //                      y también actualizo la hora de corte del nuevo precio
                //                      - ver el método del dao -
                criptomonedaDao2.updateMonedaPrecio(cmoneda);


                /*
                        ESTA ES LA SEGUNDA PARTE DEL SERVLET.  SOLO OCURRE CUANDO EL CLIENTE/USUARIO
                        QUIERE TERMINAR SU INVERSIÓN.
                        modo = "terminar" <--- viene de gestioncarrito.jsp, al terminar inversión
                 */


                // ESTO SOLO OCURRE cuando el cliente decide terminar la inversión...
                // Buscar si la criptomoneda está en el carrito.
                // Y si está en el carrito establezco el nuevo precio de la moneda.
                // necesitaré el precio actualizado para ver si ha habido ganancia o pérdida
                // ... PARA LA MONEDA QUE ESTOY ACTUALIZANDO VEO SI ESTÁ EN EL CARRITO...
                if ("terminar".equals(modo)) {
                    if (listaCarritos != null) {
                        for (Carrito carrito : listaCarritos) {
                            if (carrito.getIdCripto() == cmoneda.getId()) {
                                // Si el carrito tiene esta criptomoneda, actualizamos su precioActualizado
                                // se trata del precio que ha cambiado de la nueva moneda.
                                carrito.setPrecioActualizado(nuevoPrecio);
                            }
                        }
                    }
                }
            }     // <--- Final de recorrer todas las monedas, actualizar precio en [CriptoMonedas]
                  //      y crear nuevos registros en [COTIZACIONES]



            // LO SIGUIENTE OCURRE cuando el cliente decide terminar la inversión...
            // SEGUNDO: creo paquete del usuario.  El paquete del cliente va a la tabla [PAQUETES]
            // son todas las monedas que conformaron la inversion del cliente
            // Recorro los elementos del carrito.

            // "terminar" viene desde la página gestioncarrito.jsp, al darle al botón de terminar inversión.

            // Este código podría ir en el if anterior, visto justo arriba, pero lo he hecho así por más
            // claridad.
            if ("terminar".equals(modo)) {

                if (listaCarritos != null) {

                    // Un paquete equivale a una moneda.  Es la denominación que doy para identificar el elemento
                    // con la tabla de destino.
                    PaqueteDao paqueteDao = new PaqueteDao(database.getConnection());

                    float gananciaTotal = 0.0F;

                    for (Carrito carrito : listaCarritos) {

                        // precio final menos el inicial. la ganancia o pérdida. este valor puede ser negativo
                        float precioGanancia = (carrito.getPrecioActualizado() * carrito.getCantidad()) - (carrito.getPrecioTotal());
                        gananciaTotal += precioGanancia;

                        // Creamos el objeto Paquete para insertar en la base de datos
                        Paquete paquete = new Paquete();
                        paquete.setHoraDeCierre(momentoDeCorte); // Hora actual
                        paquete.setIdUser((Integer) session.getAttribute("id"));
                        paquete.setUsername((String) session.getAttribute("username"));
                        paquete.setIdCripto(carrito.getIdCripto());
                        paquete.setNombreMoneda(carrito.getNombreMoneda());
                        paquete.setCantidadComprada(carrito.getCantidad());
                        paquete.setPrecioCompra(carrito.getPrecioUnitario());
                        paquete.setTotalCompra(carrito.getPrecioTotal());
                        paquete.setPrecioVenta(carrito.getPrecioActualizado()); // Precio cotizado de la criptomoneda
                        paquete.setTotalVenta(carrito.getPrecioActualizado() * carrito.getCantidad());
                        paquete.setGanancia(precioGanancia);

                        // Insertamos el paquete en la base de datos
                        paqueteDao.insertPaquete(paquete);
                    }

                    // en la tabla [PAQUETES] para este cliente, se habrán creado tantos registros como monedas
                    // compradas
                    // ya he recorrido todo el objeto del carrito
                    // Ahora creo, para este usuario, el apunte de su inversión

                    // actualizo algunos datos en la sesión del usuario
                    float saldoFinal = 0.0F;
                    saldoFinal = (Float) session.getAttribute("saldo") + gananciaTotal;
                    float saldoInicial = (Float) session.getAttribute("saldo");

                    // La ganancia es la diferencia entre el saldo final y el saldo inicial
                    float ganancia = saldoFinal - saldoInicial;

                    // Si la ganancia es positiva, GananciaBool será 1 (true), de lo contrario será 0 (false)
                    boolean gananciaBool = ganancia > 0;

                    Inversion inversion = new Inversion();
                    inversion.setHoraDeCierre(momentoDeCorte);
                    inversion.setIdUsuario((Integer) session.getAttribute("id"));
                    inversion.setUsername((String) session.getAttribute("username"));
                    inversion.setSaldoInicial(saldoInicial);
                    inversion.setSaldoFinal(saldoFinal);
                    inversion.setGanancia(ganancia);
                    inversion.setGananciaBool(gananciaBool);

                    // inserto una inversion [INVERSION] para este cliente
                    InversionDao inversionDao = new InversionDao(database.getConnection());
                    boolean inversionExitosa = inversionDao.insertInversion(inversion);

                    // actualizo su saldo en la base de datos [USERS],
                    UserDao userDao = new UserDao(database.getConnection());
                    userDao.updateUserSaldo((String) session.getAttribute("username"), saldoFinal);

                    // y en la sesión. porque este cliente podría decidir realizar una nueva inversión
                    session.setAttribute("saldo", saldoFinal);

                }

                // Me deshago ahora del carrito, lo borro.  El usuario ya ha completado su inversión o compra.
                // Es decir, quito esa variable atributo del carrito de la sesión, pero no el resto de atributos
                // en sesión.
                // Y quito el carrito porque ahora podría querer volver a comprar y se crearía otro objeto carrito
                session.removeAttribute("carritos");

                // finalmente voy a la página de confirmación
                // Convertimos la cadena en un objeto LocalDateTime

                DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                String elStamp = momentoDeCorte.format(outputFormatter);

                //String elStamp = momentoDeCorte.toString();
                response.sendRedirect("resultadoinversion.jsp?momentoDeCorte=" + elStamp);
                return;

            }


            // si se ha llegado aquí redirijo a la página principal
            response.sendRedirect("index.jsp");

        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String accion = request.getParameter("accion");

        if ("borrar".equals(accion)) {
            Database database = new Database();
            try {
                database.connect();
                CotizacionDao cotizacionDao = new CotizacionDao(database.getConnection());
                cotizacionDao.borrarTodas();

                // Redirigir tras el borrado. Puedes cambiar la página si quieres otro destino.
                response.sendRedirect("index.jsp");
            } catch (ClassNotFoundException | SQLException e) {
                e.printStackTrace();
                response.sendRedirect("errorgeneral.jsp?error=Error+al+borrar+las+cotizaciones");
            }
        } else {
            response.sendRedirect("index.jsp"); // Redirección por defecto si no se especifica acción
        }
    }




    // ************************************************************************************************************
    // Métodos públicos de este procedimiento
    // ======================================
    private int Aleatorio()
    {
        // aquí calculo un nuevo porcentaje. un entero. irá entre el -25% y el 25%
        // lo hago así porque sí.
        int valorMinimo = -25;
        int valorMaximo = 25;
        Random aleatorio = new Random();

        int intAleatorio = aleatorio.nextInt(valorMaximo - valorMinimo + 1) + valorMinimo;
        return intAleatorio;
        /*
             Explicación de ésto.  Lo que hago es simular que el precio de la moneda tenga incrementos o decrementos.
             puede bajar hasta un 25% o automentar hasta un 25%.  ¿Por qué estos intervalos?  Porque se me ha ocurrido
             hacerlo así.  Y ya está.
         */

    }
}

