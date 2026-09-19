Caso propuesto: Gestión de Mantenimiento de Equipos Médicos 
1. Contexto del negocio
   
VidaSana es un centro de salud ambulatorio organizado en tres áreas: consultorios médicos, imágenes y rehabilitación. Cada área depende de equipos médicos específicos para operar.

Actualmente, el mantenimiento se registra manualmente en cuadernos de bitácora por área, y las fallas se reportan de forma informal (llamadas o mensajes). Esto genera falta de trazabilidad centralizada, incertidumbre sobre qué equipos están operativos, ausencia de control sobre repuestos y proveedores, y ninguna forma de cuantificar el impacto de las fallas en la atención a pacientes.

La Jefatura de Ingeniería Biomédica necesita responder preguntas como:

¿Qué equipos están operativos y cuáles fuera de servicio? ¿Qué área presenta mayor frecuencia de fallas? ¿Se cumple el cronograma de mantenimiento preventivo? ¿Qué proveedores responden con mayor rapidez? ¿Cuánto cuesta mantener cada equipo en el tiempo? ¿Cuántas citas se vieron afectadas por indisponibilidad de equipos? ¿Cómo evoluciona la confiabilidad de un equipo?

Se solicita diseñar una base de datos que centralice esta información y permita calcular indicadores de disponibilidad, confiabilidad y costo de mantenimiento.

. Áreas y salas de atención

VidaSana organiza sus espacios en tres áreas: consultorios, imágenes y rehabilitación.

Para cada área se registra: código único, nombre y responsable.

Para cada sala se registra: código único, área a la que pertenece, ubicación, capacidad de atención simultánea y estado (activo / en mantenimiento / inactivo).

Una sala pertenece a una única área; un área puede tener varias salas.

3. Equipos médicos

Los equipos se agrupan en categorías según el área a la que dan soporte:

Diagnóstico (consultorios): tensiómetros, linterna de examen clínico, electrocardiógrafos, balanzas, martillo de reflejos, pantoscopio, lámpara de examen clínico.
Imágenes: ecógrafo estacionario, equipo de rayos X, negatoscopio de 2 campos.
Rehabilitación: bicicleta ergométrica, tanque de compresas calientes, tanque de compresas frías, lámpara de rayos ultravioleta, equipo de terapia de onda corta, equipo de terapia con ultrasonido, equipo de magnetoterapia, estimulador nervioso transcutáneo, equipo de electroterapia.

Cada equipo pertenece a una única categoría, y cada categoría a una única área.

Para cada equipo se registra: código patrimonial único, denominación, categoría, marca, modelo, número de serie, sala asignada, fecha de adquisición, vida útil estimada, valor de adquisición, estado actual (operativo / en mantenimiento / fuera de servicio / de baja) y criticidad (alta / media / baja).

Un equipo puede cambiar de sala a lo largo del tiempo, incluso entre áreas distintas. Debe conservarse el historial de reubicaciones.

4. Mantenimiento preventivo

Un plan de mantenimiento preventivo define cada cuánto tiempo debe revisarse un equipo, independientemente de si ha fallado.

Para cada plan se registra: equipo asociado, frecuencia (mensual, trimestral, semestral, anual), actividades a realizar, fecha de inicio, fecha de la última ejecución, fecha programada de la próxima ejecución, técnico o proveedor responsable, costo estimado y estado (activo / suspendido).

Un equipo puede tener varios planes a lo largo de su vida útil.

Cada ejecución real se registra con: plan al que corresponde, fecha, duración, técnico que la realizó, hallazgos, costo real y estado (realizado / reprogramado / no realizado).

Un plan puede tener varias ejecuciones a lo largo del tiempo.

5. Incidencias y mantenimiento correctivo

Cuando un equipo falla, se registra una incidencia con: equipo afectado, fecha y hora de reporte, persona que reporta, sala donde ocurre, descripción de la falla, prioridad (urgente / media / baja), tipo de mantenimiento correctivo requerido, fecha y hora de atención, técnico o proveedor que atendió, diagnóstico técnico, repuestos utilizados (si corresponde), costo de la reparación (si corresponde), fecha/hora de inicio y de restablecimiento del servicio, y estado (reportada / en atención / resuelta / cerrada).

Un equipo puede tener varias incidencias; una incidencia corresponde a un único equipo.

Cuando un equipo queda fuera de servicio, deben poder identificarse las citas de esa sala afectadas durante ese período, indicando si fueron reprogramadas o canceladas.

6. Repuestos y proveedores

Para cada repuesto se registra: código, descripción, categoría de equipo compatible, proveedor habitual, costo unitario, stock disponible y stock mínimo.

Para cada proveedor se registra: código, razón social, RUC, tipo de servicio (mantenimiento preventivo, correctivo, ambos, venta de repuestos), tiempo de respuesta contractual y estado (activo / inactivo).

Una incidencia puede requerir uno o varios repuestos, y un repuesto puede usarse en varias incidencias. Un plan de mantenimiento preventivo también puede requerir repuestos programados (por ejemplo, cambio periódico de sensores o baterías).

7. Técnicos

Para cada técnico (interno o de proveedor externo) se registra: código, nombre completo, especialidad (electromedicina, imagenología, equipos de rehabilitación, etc.), tipo (interno / externo), proveedor al que pertenece (si es externo) y estado (activo / inactivo).

Un técnico puede atender varias incidencias y participar en varios planes de mantenimiento preventivo. Una incidencia puede ser atendida por más de un técnico a lo largo de su ciclo de vida (por ejemplo, diagnóstico y reparación por técnicos distintos).

8. Citas y afectación del servicio

VidaSana programa citas en sus distintas áreas (consulta, estudio de imagen, sesión de rehabilitación).

Para cada cita se registra: sala asignada, fecha y hora, tipo de atención y estado (programada / atendida / no asistió / cancelada / reprogramada).

Cuando una incidencia deja un equipo fuera de servicio, debe poder identificarse qué citas de la sala asociada quedaron afectadas, y si fueron reprogramadas o canceladas.

9. Información temporal

El modelo debe permitir analizar fallas, mantenimientos y disponibilidad por período: día, semana, mes, trimestre, año.

También debe permitir seguir la evolución de: incidencias por equipo, categoría y área; cumplimiento del mantenimiento preventivo; tiempo de indisponibilidad por sala y área; costos de mantenimiento; consumo de repuestos; y desempeño de proveedores y técnicos.

10. Requerimientos de análisis

El modelo debe permitir responder preguntas como:

¿Qué equipos tienen más incidencias en un período dado? ¿Cuál es el tiempo promedio de indisponibilidad por equipo, sala o área? ¿Qué porcentaje de mantenimientos preventivos se cumplió según lo programado? ¿Qué proveedor tiene el menor tiempo de respuesta? ¿Cuál es el costo total de mantenimiento por equipo, categoría y área? ¿Qué área acumula mayor indisponibilidad de equipos críticos? ¿Cómo evoluciona mensualmente la cantidad de incidencias por tipo de equipo? ¿Qué equipos están próximos a cumplir su vida útil? ¿Qué repuestos se consumen con mayor frecuencia y en qué equipos? ¿Qué técnicos resuelven más incidencias y en qué tiempo promedio? ¿Cuántas citas fueron canceladas o reprogramadas por fallas, y en qué área? ¿Qué equipos generan mayor costo acumulado respecto a su valor de adquisición? ¿Qué categoría presenta menor confiabilidad (mayor tasa de fallas por unidad de tiempo)?

11. Reglas de negocio
Un área puede tener varias salas; una sala pertenece a una única área.
Un equipo pertenece a una única sala en un momento dado, pero puede ser reubicado en el tiempo.
Un equipo pertenece a una única categoría; una categoría pertenece a una única área.
Un equipo puede tener varios planes de mantenimiento preventivo a lo largo de su vida útil.
Un plan de mantenimiento preventivo puede tener varias ejecuciones.
Un equipo puede generar varias incidencias; una incidencia corresponde a un único equipo.
Una incidencia puede ser atendida por uno o varios técnicos.
Una incidencia puede requerir cero, uno o varios repuestos; un repuesto puede usarse en varias incidencias.
Un plan de mantenimiento preventivo puede requerir repuestos programados.
Un técnico puede participar en varias incidencias y varios mantenimientos preventivos.
No toda incidencia requiere un repuesto.
Una cita puede verse afectada, como máximo, por la incidencia vigente en su sala durante su horario programado.
No todas las citas se ven afectadas por incidencias.
La información histórica (incidencias, mantenimientos, reubicaciones, citas) no debe perderse al cambiar los datos actuales del equipo, la sala o el proveedor.
El estado actual de un equipo debe poder determinarse a partir de su historial de incidencias y mantenimientos.
Un proveedor puede estar asociado a varios técnicos externos.
Un repuesto puede tener un proveedor habitual, pero el histórico de compras puede registrar proveedores distintos en el tiempo.
