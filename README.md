# NataWeb

![Java](https://img.shields.io/badge/Java-17-red)
![Maven](https://img.shields.io/badge/Maven-Build-blue)
![Tomcat](https://img.shields.io/badge/Tomcat-11.0.4-orange)
![MariaDB](https://img.shields.io/badge/Database-MariaDB-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**NataWeb** es una aplicación web que simula una plataforma de inversión en criptomonedas, orientada a clientes registrados.
**NataWeb** is a web application that simulates a cryptocurrency investment platform, designed for registered clients.

---

## 🚀 Características principales | Main Features

### 👤 Para clientes | For Clients

* **Registro y gestión de cuenta**: creación de usuario, actualización de datos y modificación de información personal.
  **Account management**: user registration, profile update, and personal data modification.

* **Operaciones de inversión**: consultar listado de criptomonedas disponibles, añadirlas a la cartera y cerrar inversiones.
  **Investment operations**: browse available cryptocurrencies, add them to a portfolio, and close investments.

* **Cartera de inversiones**: cada inversión puede contener uno o varios paquetes (cantidades específicas adquiridas en un momento dado).
  **Investment portfolio**: each investment may contain one or multiple packages (specific amounts purchased at a given time).

* **Opiniones**: registrar, modificar, listar y eliminar opiniones sobre inversiones finalizadas.
  **Feedback**: add, edit, list, and delete reviews of completed investments.

* **Historial**: acceso completo a las inversiones pasadas, con posibilidad de eliminarlas.
  **History**: full access to past investments, with the option to delete them.

### 🛠️ Para administradores | For Administrators

* **Gestión de criptomonedas**: operaciones CRUD (crear, leer, actualizar, eliminar).
  **Cryptocurrency management**: full CRUD operations (create, read, update, delete).

* **Gestión de clientes**: visualizar detalles y habilitar/inhabilitar cuentas.
  **User management**: view details and enable/disable accounts.

* **Mantenimiento del sistema**: registrar y administrar tareas de mantenimiento.
  **System maintenance**: register and manage maintenance tasks.

* **Cotizaciones**: acceso al historial completo de cotizaciones de todas las criptomonedas (habilitadas o no), con opción de eliminar registros.
  **Price history**: access to the full quotation history of all cryptocurrencies (enabled or not), with the option to delete records.

---

## 🗄️ Base de datos | Database

La aplicación utiliza **MariaDB**, gestionada con **MySQL** y administrada visualmente con **DBeaver**.
The application uses **MariaDB**, managed with **MySQL** and visually administered with **DBeaver**.

### Tablas principales | Main Tables

1. **Usuarios | Users**
2. **Inversiones | Investments**
3. **Criptomonedas | Cryptocurrencies**
4. **Cotizaciones | Quotations**
5. **Paquetes | Packages**
6. **Opiniones | Reviews**
7. **Tareas de mantenimiento | Maintenance tasks**

---

## ⚙️ Tecnologías utilizadas | Technologies Used

* **Backend:** Java con **Apache Tomcat 11.0.4**
  **Backend:** Java with **Apache Tomcat 11.0.4**

* **IDE:** IntelliJ IDEA

* **Gestión de dependencias:** Maven
  **Dependency management:** Maven

* **Bibliotecas externas:** [Lombok](https://projectlombok.org/)
  **External libraries:** [Lombok](https://projectlombok.org/)

* **Base de datos:** MariaDB/MySQL
  **Database:** MariaDB/MySQL

* **Administrador BD:** DBeaver
  **DB Admin Tool:** DBeaver

---


## 📚 Funcionalidades futuras | Future Features

* Implementación de notificaciones automáticas sobre variaciones en las cotizaciones.
  **Automatic notifications** on quotation variations.

* Reportes gráficos del rendimiento de inversiones.
  **Graphical reports** of investment performance.

* Integración con APIs externas de precios en tiempo real.
  **Integration with external APIs** for real-time price data.

---

## 👥 Autores | Authors

Proyecto desarrollado como simulador de plataforma de inversión en criptomonedas con fines académicos y prácticos.
Project developed as a cryptocurrency investment platform simulator for academic and practical purposes.

Natalia Garré Ramo - 2025

---
