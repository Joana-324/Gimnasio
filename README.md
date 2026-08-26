# Propuesta de Trabajo Final Integrador (TFI)
## 0. Información del grupo
Grupo N°:   127
Tutor/a: Grosso, María Candela

Integrantes:
- Fulladoza, Pablo Facundo
- Lauk, Karen Yamila
- Noguera Ríos, Joana Soledad
  
## Sistema de Gestión Integrada para Gimnasios (GymFlow)

---
### 1. Identificación y Definición de la Problemática

#### Contexto y Actores Afectados
El proyecto se sitúa en el ámbito de los centros de entrenamiento de escala media (gimnasios de barrio o centros deportivos locales). En estos establecimientos coexisten tres actores clave con necesidades insatisfechas debido a la ausencia de una herramienta integrada:
1. **Administradores / Dueños:** Encargados de dar de alta clientes, controlar los cobros, gestionar las membresías y vigilar el estado de los pagos.
2. **Instructores / Profesores:** Responsables de diseñar, planificar y asignar rutinas de ejercicios personalizadas a cada afiliado de acuerdo con sus objetivos.
3. **Clientes / Afiliados:** Usuarios finales que asisten al establecimiento para entrenar, quienes necesitan consultar sus rutinas actualizadas y verificar su situación administrativa (créditos y estado de cuenta).

#### Ineficiencias Toleradas e Impacto Medible
Actualmente, el flujo de trabajo opera bajo ineficiencias toleradas que generan pérdidas económicas y fricción administrativa:
* **Fuga de Ingresos por Descontrol de Pagos:** La comunicación de mensualidades vencidas o faltas de pago se gestiona manualmente mediante recordatorios individuales por números de celular personales (WhatsApp/Telegram). Al no existir un sistema de bloqueo de accesos o alertas inmediatas, se permite el ingreso involuntario de alumnos con saldos impagos, impactando directamente en la recaudación mensual.
* **Fricción Operativa en la Gestión de Rutinas:** Los instructores diseñan planes generales en pizarras o en planillas físicas de papel. Estos formatos se pierden con facilidad, son difíciles de encontrar para el alumno durante su sesión de entrenamiento y demandan tiempo del instructor para reescribirlos. En otros casos, los entrenadores deben utilizar sus chats personales para enviar fotos o archivos con las rutinas, mezclando el ámbito laboral con el privado.

#### Propuesta de Valor Agregado
La plataforma resolverá estas ineficiencias centralizando el flujo administrativo y operativo:
* **Para Administración:** Notificación instantánea y visual del estado del cliente al momento de registrar su asistencia, reduciendo la morosidad y automatizando el control de acceso.
* **Para Instructores:** Digitalización y personalización dinámica de las rutinas de entrenamiento mediante plantillas modificables, ahorrando horas semanales de transcripción y eliminando el papel.
* **Para Clientes:** Acceso transparente y ágil a su rutina y estado financiero desde su teléfono celular en tiempo real, sin necesidad de consultar físicamente al personal.

---

### 2. Alcance del Proyecto (MVP y No Alcance)

Para garantizar la viabilidad temporal del desarrollo dentro de los plazos académicos de la Tecnicatura (vencimiento de entrega final el 14/11), se definen estrictamente los límites del Producto Mínimo Viable:

#### Funcionalidades Incluidas (MVP)
* **Módulo de Autenticación y Roles:** Control de accesos mediante login diferenciado para tres roles: Administrador, Instructor y Cliente.
* **Módulo de Administración:** Alta, modificación y baja de afiliados. Configuración de diversos tipos de suscripciones (Pase Libre, Pase por Créditos, Clases específicas semanales).
* **Módulo de Instructores:** Diseñador digital de rutinas variables (ejercicios, series, repeticiones, observaciones) y asignación directa a la cuenta de un afiliado.
* **Módulo de Asistencia (Tablet Fija):** Interfaz simplificada diseñada para una tablet fija en la puerta del gimnasio. El cliente registra su ingreso (ej. mediante DNI o código numérico), y el sistema emite una alerta visual inmediata sobre su estado de pago (Habilitado / Alerta de Impago).
* **Módulo del Cliente (Web Responsive):** Interfaz adaptable a dispositivos móviles donde el cliente puede consultar su rutina del día y revisar el estado de su cuenta (vencimientos de pases y créditos restantes).

#### Funcionalidades Excluidas (Fuera de Alcance)
* **Pasarela de Pagos en Línea:** El cobro seguirá registrándose manualmente por el administrador en recepción. No se integrarán APIs de pago real (Mercado Pago, Stripe, etc.) para evitar demoras por dependencias externas y configuraciones complejas.
* **Registro de Asistencia Automático por App Móvil:** No se implementará geolocalización, bluetooth ni códigos QR dinámicos para el ingreso desde el dispositivo personal del cliente.

---

### 3. Stack Tecnológico Justificado

Con el fin de mitigar riesgos técnicos y optimizar el tiempo de desarrollo frente a la curva de aprendizaje, se ha seleccionado el siguiente conjunto de tecnologías:

#### Frontend (Lado del Cliente)
* **Tecnologías:** HTML5, CSS3 y JavaScript (JS) nativo.
* **Justificación:** Al no utilizar frameworks complejos de frontend (como Angular o React), el equipo minimiza la sobreingeniería y se enfoca en el desarrollo ágil de interfaces limpias y totalmente responsivas (adaptables a computadoras, móviles y tablets) mediante media queries estándar de CSS.

#### Backend (Lado del Servidor)
* **Lenguaje y Entorno:** Node.js.
* **Framework:** Express.js.
* **Justificación:** Node.js permite unificar el lenguaje de programación (JavaScript) tanto en el cliente como en el servidor, agilizando la escritura de código. Express es un framework minimalista y maduro con una amplísima comunidad y librerías pre-construidas que resuelven de forma sencilla el enrutamiento API y la conexión a las bases de datos.

#### Bases de Datos (Persistencia Políglota)
El proyecto implementará un esquema híbrido que equilibra robustez transaccional con flexibilidad documental:
1. **Relacional (MySQL):** Motor principal para la gestión de usuarios, asignación de roles (administrador, instructor, cliente), registro de membresías y transacciones de pago. Se justifica por la necesidad de integridad transaccional estricta (cumplimiento de propiedades ACID) para asegurar la consistencia financiera de los créditos y evitar duplicación de información.
2. **No Relacional (MongoDB):** Utilizada exclusivamente para el almacenamiento dinámico y la entrega de las rutinas de ejercicios. Las rutinas son de naturaleza jerárquica y variable (una rutina contiene días variables, que contienen ejercicios con atributos disímiles como peso, repeticiones, tiempo de descanso o notas especiales). El modelo de documentos JSON/BSON de MongoDB se adapta de forma orgánica a esta flexibilidad, permitiendo almacenar la rutina de un alumno como un solo documento sin requerir múltiples "joins" complejos.
* **Plan de Mitigación:** En caso de presentarse bloqueos severos en la sincronización o conexión de ambos entornos, el equipo migrará el flujo de rutinas hacia MySQL utilizando tablas intermedias estructuradas (`Rutinas`, `Ejercicios` y `Rutina_Ejercicios`), garantizando así que el proyecto no se detenga.

#### Plataformas de Despliegue en la Nube
Para cumplir con la obligatoriedad del TFI de contar con despliegue en la nube, se planifica la siguiente arquitectura PaaS (Plataforma como Servicio), lo cual abstrae la gestión de servidores y se asocia directamente al repositorio de GitHub:
* **Frontend:** Alojado de manera gratuita en **Vercel** o **Netlify**. Cada actualización del código en GitHub compilará y actualizará la app de forma automatizada.
* **Backend (API):** Desplegado en **Render**, vinculando las variables de entorno de forma segura para las credenciales de bases de datos.
* **Base de Datos NoSQL:** Alojada de forma gratuita en la nube oficial de **MongoDB Atlas**.
* **Base de Datos SQL:** Alojada en **Aiven** o **Railway** con una instancia gestionada de MySQL.

---

### 4. Plan de Trabajo Inicial (Línea de Tiempo)

* **Etapa 1 (Hasta 30/08) - Planificación y Repositorio:** Presentación oficial de la propuesta técnica y creación del repositorio Git unificado de la materia.
* **Etapa 2 (Hasta 27/09) - Diseño de Base de Datos y APIs:** Maquetado de la base de datos relacional (MySQL) y documental (MongoDB). Definición del árbol de rutas de Express para la API. Presentación del diseño de base de datos para aprobación del tutor (Regularidad).
* **Etapa 3 (Hasta 25/10) - Desarrollo de Backend y Frontend:** Programación de la lógica de negocio (registro, control de pagos, asignación de rutinas). Desarrollo de las pantallas responsivas de administración, instructor y cliente.
* **Etapa 4 (Hasta 14/11) - Despliegue, Pruebas y Video:** Vinculación de los servicios en la nube (Vercel, Render, bases de datos remotas). Corrección de errores cruzados. Redacción del informe final y grabación del video demostrativo explicativo (en inglés).
