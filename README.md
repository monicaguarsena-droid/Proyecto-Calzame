# 👟 CALZAME - SISTEMA DE PEDIDOS Y GESTIÓN DE CATÁLOGO

SISTEMA INTEGRAL RESTful PARA GESTIONAR EL CATÁLOGO DE PRODUCTOS, PEDIDOS, INVENTARIO Y ATENCIÓN DE CLIENTES, DESARROLLADO CON TECNOLOGÍA MODERNA.

---

## 🛠️ Stack Tecnológico

El proyecto utiliza una arquitectura moderna basada en un servidor backend API REST y una base de datos en la nube, integrando las siguientes tecnologías:

* **Node.js + Express** (backend)
* **Supabase** (base de datos y almacenamiento)
* **Cloudinary** (gestión de imágenes de productos)
* **Brevo** (envío de correos transaccionales)
* **JWT & Bcrypt** (autenticación y encriptación)

---

## 🚀 Características del Proyecto

### 🔒 1. Autenticación y Seguridad
* **Registro e Inicio de Sesión:** Autenticación segura para usuarios mediante tokens (JWT) y verificación de cuenta por código vía correo electrónico.
* **Control de Acceso Basado en Roles (RBAC):** Vistas y permisos diferenciados para perfiles de Cliente y Administrador.
* **Protección de Rutas:** Middlewares en el backend para restringir el acceso a endpoints sensibles según el rol.
* **Gestión de Sesión:** Cierre de sesión seguro y expiración automática de credenciales.

### 📦 2. Gestión Operativa y Comercial
* **Gestión de Catálogo:** Control CRUD completo de productos (tallas, colores, stock) y categorías de calzado.
* **Módulo de Pedidos:** Flujo completo de órdenes de compra, seguimiento de estados y transacciones de los clientes.
* **Panel Administrativo:** Control de inventario y visualización de ventas en tiempo real.
* **Mensajería y Soportes:** Sistema de retroalimentación de usuarios y chat interno de atención.

---

## ⚙️ Instalación y Configuración

### 1. Clonar el repositorio

* Git clone https://github.com/monicaguarsena-droid/Proyecto-Calzame.git
* Instalar en node.js
* Ejecutar npm install
* Instalar librerias de express y supabase
  
---

## Ejecución del servidor 

*  npm run dev

---

## 📂Estructura del proyecto
``
* Proyecto-Calzame/
├── backend/

│   ├── config/ # Configuración de Supabase y Cloudinary

│   ├── controllers/        # Lógica para usuarios, productos, pedidos, etc.

│   ├── middlewares/        # Validación de JWT y control de roles

│   ├── models/             # Consultas y esquemas de base de datos en Supabase

│   ├── routes/             # Definición de rutas API REST

│   └── utils/              # Servicios auxiliares (envío de emails, tokens, respuestas)

├── node_modules/           # Dependencias instaladas

├── .env                    # Variables de entorno

├── .gitignore              # Archivos y carpetas ignorados por Git

├── index.js                # Servidor principal Express

├── package-lock.json       # Registro de versiones exactas de dependencias

└── package.json            # Configuración del proyecto y dependencias

``

## Auctores/ Equipo de Desarrollo
*  **Monica Molina**
    * **Rol:** Desarrollador Backend
    * **Especialidad:** Arquitectura de APIS REST, Node.js, Express Y gestión de bases de datos
    
*  **Evelyn Arrigui**
    * **Rol:** Desarrollador Backend
    * **Especialidad:** Arquitectura de APIS REST, Node.js, Express Y gestión de bases de datos

