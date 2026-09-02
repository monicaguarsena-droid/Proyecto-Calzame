                                          👠 CALZAME


Una aplicación para administrar una tienda de calzado, controlar los productos, los pedidos y las cuentas de los usuarios de forma rápida y sencilla.



                                            HERAMIENTAS
Servidor Backend: Hecho con Node.js y Express para manejar las conexiones y la seguridad con tokens.

Base de Datos: Supabase par guardar toda la información de los usuarios y la tienda.

Correos: Nodemailer para enviar los códigos de verificación y las confirmaciones de compra.




                                          QUE HACE EL PROYECTO
Cuentas seguras: Los usuarios se registran, reciben un código de 6 dígitos en su correo para activar la cuenta y pueden iniciar sesión con seguridad.

Control de Pedidos: Permite registrar y confirmar compras, enviando avisos automáticos por correo.

Gestión de la Tienda: Administra el catálogo de zapatos y la información de los clientes desde la base de datos.


                                          COMO INTALARLO Y EJECUTARLO
Pasos para poner a funcionar el servidor en tu computadora:

Clona el repositorio
Instalación de Node.

Instalar dependencias con
Bash
npm install
Instalar librerías de Node (express y supabase).

Ejecutar el servidor
Bash
npm run dev

                                          📂 Organización de carpetas
Plaintext
BACKEND/
├── config/         # Conexión con Supabase
├── controllers/    # Lógica principal (como el registro y login)
├── modelos/        # Consultas a la base de datos
├── utils/          # Envío de correos
└── index.js        # Archivo que arranca el servidor


                                          ✍️ Autor
Jimmy Alexander Lombana Rivera

Ingeniero de Sistemas | Desarrollador Full-Stack

Especialidad: Desarrollo de aplicaciones móviles y web, arquitecturas cliente-servidor e integración de APIs RESTful.
