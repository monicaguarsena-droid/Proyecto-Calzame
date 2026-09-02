                                     👠 CALZAME

Una plataforma tecnológica diseñada para administrar un negocio de calzado y sus pedidos Facilitar y automatizar la gestión integral de la tienda, optimizando el control de productos, la administración de usuarios y el procesamiento de pedidos de manera eficiente.


LO QUE USAMOS

Servidor Backend Hecho con Node.js y Express para manejar las conexiones y la seguridad con tokens.

Base de Datos: Supabase para guardar toda la información de los usuarios y la tienda.

Correos: Nodemailer para enviar los códigos de verificación y las confirmaciones de compra.


QUE HACE EL PROYECTO
Cuentas seguras: Los usuarios se registran, reciben un código de 6 dígitos en su correo para activar la cuenta y pueden iniciar sesión con seguridad.

Control de Pedidos: Permite registrar y confirmar compras, enviando avisos automáticos por correo.

Gestión de la Tienda: Administra el catálogo de zapatos y la información de los clientes desde la base de datos.



Cómo instalarlo y ejecutarlo
git clone
npm install
npm run dev



BACKEND/
 config/         # Conexión con Supabase
 controllers/    # Lógica principal (como el registro y login)
 modelos/        # Consultas a la base de datos
 utils/          # Envío de correos
 index.js        # Archivo que arranca el servidor



