Caso propuesto: Gestión de Mantenimiento de Equipos Médicos 
1. Contexto del negocio
   
VidaSana es un centro de salud ambulatorio organizado en tres áreas: consultorios médicos, área de imágenes y área de fisioterapia. Cada área depende de equipos médicos específicos para operar.

Actualmente, el mantenimiento de estos equipos se registra de forma manual en cuadernos de bitácora por área, y las fallas se reportan de manera informal (llamadas telefónicas o mensajes). Esto genera dificultades: no hay trazabilidad centralizada del historial de mantenimiento, no se sabe con certeza qué equipos están operativos en un momento dado, no existe control sobre repuestos ni sobre el desempeño de los proveedores de servicio técnico, y no se puede cuantificar el impacto de las fallas sobre la atención a pacientes.

La Jefatura de Ingeniería Biomédica necesita responder preguntas como:

¿Qué equipos están operativos y cuáles fuera de servicio en este momento? ¿Qué área presenta mayor frecuencia de fallas? ¿Se cumplió el cronograma de mantenimiento preventivo? ¿Qué proveedores de servicio técnico responden con mayor rapidez? ¿Cuánto cuesta mantener cada equipo a lo largo del tiempo? ¿Cuántas citas o sesiones se vieron afectadas por la indisponibilidad de un equipo? ¿Cómo evoluciona la confiabilidad de un equipo en el tiempo?

Para ello, se solicita diseñar una base de datos que permita centralizar esta información y posteriormente generar indicadores de disponibilidad, confiabilidad y costo de mantenimiento.   

2. Información de las áreas y salas de atención

VidaSana organiza sus espacios físicos en tres áreas: Consultorios. Imágenes. Rehabilitación.

Para cada área se necesita registrar: Código único del área. Nombre del área. Responsable del área. 

Para cada sala/ambiente requiere registrar: Código único de la sala. Área a la que pertenece. Ubicación (piso o ala del local). Capacidad de atención simultánea. Estado (activo / en mantenimiento / inactivo). 

Una sala pertenece a una única área. Un área puede tener varias salas.

3. Información de los equipos médicos

Los equipos médicos se clasifican por categorías según el área a la que dan soporte:

Equipos de diagnóstico: tensiómetros, lintera para examen clinico electrocardiógrafos, balanzas, martillo de reflejos, pantoscopio, lampara de examen clinico.  
Equipos de imágenes: ecógrafo estacionario, equipos de rayos X, negatoscopio de 2 campos.
Equipos de rehabilitación: bicicleta ergonometrica, tanque de compresas calientes, tanque de compresas frias, lampara de rayos ultravioleta, equipo de terapia de onda corta, equipo de terapia con ultrasonido, equipo de magnoterapia, estimulador nervioso transcutaneo, equipo de electroterapia.

Cada equipo pertenece a una determinada categoría, y cada categoría pertenece a un área.

Para cada equipo se desea almacenar:

Código patrimonial único del equipo. Denominación. Categoría. Marca. Modelo. Número de serie. Sala asignada actualmente. Fecha de adquisición. Vida útil estimada. Valor de adquisición. Estado actual (operativo / en mantenimiento / fuera de servicio / de baja). Criticidad del equipo (alta / media / baja).

Un equipo puede cambiar de sala a lo largo del tiempo (reubicación), incluso entre áreas distintas. Se debe conservar el historial de reubicaciones.

4. Mantenimiento preventivo

El mantenimiento preventivo define, de forma recurrente, cada cuánto tiempo debe revisarse un equipo, independientemente de si ha fallado.

Para cada plan de mantenimiento preventivo se necesita conocer:

Equipo asociado. Frecuencia (mensual, trimestral, semestral, anual). Fecha de inicio del plan. Fecha de la última ejecución. Fecha programada de la próxima ejecución. Técnico o proveedor responsable. Costo estimado por ejecución. Estado del plan (activo / suspendido). Actividades a realizar.

Cada ejecución real de un mantenimiento preventivo debe quedar registrada con:

Plan al que corresponde. Fecha real de ejecución. Duración. Técnico que la realizó. Hallazgos. Costo real. Estado (realizado / reprogramado / no realizado).

Un plan de mantenimiento preventivo puede tener varias ejecuciones a lo largo del tiempo.

5. Incidencias y mantenimiento correctivo

Cuando un equipo presenta una falla, se registra una incidencia.

Para cada incidencia se requiere conocer:

Equipo afectado. Fecha y hora de reporte. Persona que reporta. Sala donde ocurre. Descripción de la falla. Prioridad de atención (urgente / media / baja). Tipo de mantenimiento correctivo requerido. Fecha y hora de atención. Técnico o proveedor que atendió. Diagnóstico técnico. Repuestos utilizados, si corresponde. Costo de la reparación, si corresponde. Fecha/hora de inicio y de restablecimiento del servicio. Estado de la incidencia (reportada / en atención / resuelta / cerrada).

Un equipo puede tener varias incidencias a lo largo de su vida útil. Una incidencia corresponde a un único equipo.

Cuando un equipo queda fuera de servicio, las citas programadas en su sala que dependen de ese equipo deben poder identificarse como afectadas (reprogramadas o canceladas), relacionando la incidencia con las citas impactadas.

6. Repuestos y proveedores

Para los repuestos se necesita registrar:

Código del repuesto. Descripción. Categoría de equipo compatible. Proveedor habitual. Costo unitario. Stock disponible. Stock mínimo.

Para los proveedores de servicio técnico se necesita registrar:

Código del proveedor. Razón social. RUC. Tipo de servicio que ofrece (mantenimiento preventivo, correctivo, ambos, venta de repuestos). Tiempo de respuesta contractual. Estado (activo / inactivo).

Una incidencia puede requerir uno o varios repuestos, y un repuesto puede utilizarse en varias incidencias distintas. Un plan de mantenimiento preventivo también puede requerir repuestos programados (por ejemplo, cambio periódico de sensores o baterías).

7. Técnicos

Para cada técnico (interno o de un proveedor externo) se requiere conocer:

Código del técnico. Nombre completo. Especialidad (electromedicina, imagenología, equipos de rehabilitación, etc.). Tipo (interno / externo). Proveedor al que pertenece, si es externo. Estado (activo / inactivo).

Un técnico puede atender varias incidencias y participar en varios planes de mantenimiento preventivo. Una incidencia puede ser atendida por uno o varios técnicos a lo largo de su ciclo de vida (por ejemplo, un primer diagnóstico y luego la reparación por otro técnico).

8. Citas y afectación del servicio

VidaSana programa citas para pacientes en las distintas áreas (consulta, estudio de imagen, sesión de rehabilitación).

Para cada cita se requiere conocer, al menos:

Sala asignada. Fecha y hora. Tipo de atención. Estado de la cita (programada / atendida / no asistió / cancelada / reprogramada).

Cuando una incidencia deja un equipo fuera de servicio, se debe poder identificar qué citas de la sala asociada quedaron afectadas durante ese período, y si fueron reprogramadas o canceladas.

9. Información temporal

La Jefatura desea analizar la evolución histórica de fallas, mantenimientos y disponibilidad.

Por ejemplo: un equipo pudo tener 1 incidencia en enero, 3 en febrero y 0 en marzo.

Por ello, el modelo debe permitir analizar la información por diferentes períodos:

Día. Semana. Mes. Trimestre. Año.

También se desea conocer la evolución de:

Incidencias por equipo, categoría y área. Cumplimiento del mantenimiento preventivo. Tiempo de indisponibilidad por sala y por área. Costos de mantenimiento (preventivo y correctivo) por equipo. Consumo de repuestos. Desempeño de proveedores y técnicos.

10. Requerimientos de análisis

El modelo resultante debe permitir responder preguntas como:

¿Qué equipos tienen mayor cantidad de incidencias en un período determinado? ¿Cuál es el tiempo promedio de indisponibilidad por equipo, por sala o por área? ¿Qué porcentaje de mantenimientos preventivos se cumplió según lo programado? ¿Qué proveedor tiene el menor tiempo de respuesta ante incidencias? ¿Cuál es el costo total de mantenimiento (preventivo + correctivo) por equipo, por categoría y por área? ¿Qué área acumula mayor tiempo de indisponibilidad de equipos críticos? ¿Cómo evoluciona mensualmente la cantidad de incidencias por tipo de equipo? ¿Qué equipos están próximos a cumplir su vida útil estimada? ¿Qué repuestos se consumen con mayor frecuencia y en qué equipos? ¿Qué técnicos resuelven mayor cantidad de incidencias y en qué tiempo promedio? ¿Cuántas citas fueron canceladas o reprogramadas por fallas de equipos, y en qué área? ¿Qué equipos generan mayor costo acumulado en relación con su valor de adquisición? ¿Qué categoría de equipo presenta menor confiabilidad (mayor tasa de fallas por unidad de tiempo)?

11. Reglas de negocio iniciales

Un área puede tener varias salas; una sala pertenece a una única área. Un equipo pertenece a una única sala en un momento dado, pero puede ser reubicado en el tiempo. Un equipo pertenece a una única categoría; una categoría pertenece a una única área. Un equipo puede tener varios planes de mantenimiento preventivo a lo largo de su vida útil. Un plan de mantenimiento preventivo puede tener varias ejecuciones a lo largo del tiempo. Un equipo puede generar varias incidencias; una incidencia corresponde a un único equipo. Una incidencia puede ser atendida por uno o varios técnicos. Una incidencia puede requerir cero, uno o varios repuestos; un repuesto puede utilizarse en varias incidencias. Un plan de mantenimiento preventivo puede requerir repuestos programados. Un técnico puede participar en varias incidencias y en varios mantenimientos preventivos. No toda incidencia requiere necesariamente un repuesto. Una cita puede verse afectada por, como máximo, la incidencia vigente en su sala durante su horario programado. No todas las citas se ven afectadas por incidencias. La información histórica de incidencias, mantenimientos, reubicaciones y citas no debe perderse cuando cambien los datos actuales del equipo, la sala o el proveedor. El estado actual de un equipo debe poder determinarse a partir de su historial de incidencias y mantenimientos. Un proveedor puede estar asociado a varios técnicos externos. Un repuesto puede provenir de un único proveedor habitual, pero el histórico de compras puede registrar proveedores distintos a lo largo del tiempo.
