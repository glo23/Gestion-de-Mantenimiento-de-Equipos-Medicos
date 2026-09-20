# Caso propuesto: Gestión de Mantenimiento de Equipos Médicos 
## Contexto del negocio

VidaSana es un centro de salud ambulatorio organizado en tres áreas: consultorios médicos, imágenes y rehabilitación. Cada área depende de equipos médicos específicos para operar.

Actualmente, el mantenimiento se registra manualmente en cuadernos de bitácora por área, y las fallas se reportan de forma informal (llamadas o mensajes). Esto genera falta de trazabilidad centralizada, incertidumbre sobre qué equipos están operativos, ausencia de control sobre repuestos y proveedores, y ninguna forma de cuantificar el impacto de las fallas en la atención a pacientes.

La Jefatura de Ingeniería Biomédica necesita responder preguntas como:

¿Qué equipos están operativos y cuáles fuera de servicio? ¿Qué área presenta mayor frecuencia de fallas? ¿Se cumple el cronograma de mantenimiento preventivo? ¿Qué proveedores responden con mayor rapidez? ¿Cuánto cuesta mantener cada equipo en el tiempo? ¿Cuántas citas se vieron afectadas por indisponibilidad de equipos? ¿Cómo evoluciona la confiabilidad de un equipo?

Se solicita diseñar una base de datos que centralice esta información y permita calcular indicadores de disponibilidad, confiabilidad y costo de mantenimiento.

## 1. Área

Código único y nombre. Una sola área agrupa varias salas.

## 2. Sala

Código único, área a la que pertenece, ubicación y estado (activo / en mantenimiento / inactivo). Una sala pertenece a una única área.

## 3. Equipo médico

Código patrimonial único, denominación, categoría (define a qué área da soporte: diagnóstico, imágenes o rehabilitación), marca, modelo, número de serie, sala asignada actualmente, fecha de adquisición, vida útil estimada, valor de adquisición, estado actual (operativo / en mantenimiento / fuera de servicio / de baja) y criticidad (alta / media / baja).

Categorías por área:
- **Diagnóstico**: tensiómetros, linterna de examen clínico, electrocardiógrafos, balanzas, martillo de reflejos, pantoscopio, lámpara de examen clínico.
- **Imágenes**: ecógrafo estacionario, equipo de rayos X, negatoscopio de 2 campos.
- **Rehabilitación**: bicicleta ergométrica, tanque de compresas calientes, tanque de compresas frías, lámpara de rayos ultravioleta, equipo de terapia de onda corta, equipo de terapia con ultrasonido, equipo de magnetoterapia, estimulador nervioso transcutáneo, equipo de electroterapia.

## 4. Historial de ubicaciones de equipo

Equipo, sala anterior (vacía si es la primera ubicación del equipo), sala nueva (siempre obligatoria y distinta de la anterior), fecha del cambio y motivo. Registra cada reubicación de un equipo entre salas, incluso entre áreas distintas, sin perder la ubicación actual.

## 5. Plan de mantenimiento preventivo

Equipo asociado, frecuencia (mensual, trimestral, semestral, anual), actividades a realizar, fecha de inicio, fecha programada de la próxima ejecución, costo estimado y estado (activo / suspendido). Un equipo puede tener varios planes a lo largo de su vida útil.

## 6. Ejecución de mantenimiento preventivo

Plan al que corresponde, técnico que la realizó, fecha, hallazgos, costo real y estado (realizado / reprogramado / no realizado). Un plan puede tener varias ejecuciones a lo largo del tiempo.

## 7. Incidencia

Equipo afectado, fecha y hora de reporte, persona que reporta, cargo de quien reporta, descripción de la falla, prioridad (urgente / media / baja) y estado (reportada / en atención / resuelta / cerrada). Un equipo puede tener varias incidencias; una incidencia corresponde a un único equipo.

## 8. Parada de equipo

Tipo de parada (programada / no programada), fecha/hora de inicio y fecha/hora de fin. Se origina exclusivamente por una **incidencia** o por una **ejecución de mantenimiento preventivo** (nunca por ambas a la vez ni por ninguna), lo que permite tratar de forma unificada tanto las paradas imprevistas como las programadas.

## 9. Mantenimiento correctivo

Parada de equipo asociada, técnico interno que atiende (siempre obligatorio, es quien atiende primero), técnico externo (opcional — solo si el técnico interno escala el caso a un proveedor), acciones realizadas, fecha de atención, costo total y estado.

## 10. Repuesto

Código, descripción, proveedor habitual, costo unitario, stock disponible y stock mínimo (para alertas de reposición).

## 11. Cuantificación de repuestos

Ejecución preventiva o mantenimiento correctivo al que pertenece (exclusivamente uno de los dos), repuesto utilizado, cantidad y costo unitario en ese momento. Registra cada uso individual de un repuesto, tanto en mantenimientos preventivos como correctivos.

## 12. Proveedor

Código, razón social, RUC y tiempo de respuesta contractual.

## 13. Técnico

Código, nombre completo, especialidad (electromedicina, imagenología, equipos de rehabilitación, etc.), tipo (interno / externo), proveedor al que pertenece (si es externo) y estado (activo / inactivo). Un técnico interno no está asociado a ningún proveedor.

## 14. Reprogramación de cita por parada de equipo

Parada relacionada, sala, fecha y hora original de la cita, y fecha y hora nueva (si fue reprogramada; si quedó cancelada, este campo permanece vacío). Una parada de equipo puede afectar cero, una o varias citas.

## 15. Información temporal

El modelo debe permitir analizar fallas, mantenimientos y disponibilidad por período: día, semana, mes, trimestre, año.

También debe permitir seguir la evolución de: incidencias por equipo, categoría y área; cumplimiento del mantenimiento preventivo; tiempo de indisponibilidad por sala y área; costos de mantenimiento; consumo de repuestos; y desempeño de proveedores y técnicos.

## 16. Requerimientos de análisis

¿Qué equipos tienen más incidencias en un período dado? ¿Cuál es el tiempo promedio de indisponibilidad por equipo, sala o área? ¿Qué porcentaje de mantenimientos preventivos se cumplió según lo programado? ¿Qué proveedor tiene el menor tiempo de respuesta? ¿Cuál es el costo total de mantenimiento (mano de obra + repuestos) por equipo, categoría y área? ¿Qué área acumula mayor indisponibilidad de equipos críticos? ¿Cómo evoluciona mensualmente la cantidad de incidencias por tipo de equipo? ¿Qué equipos están próximos a cumplir su vida útil? ¿Qué repuestos se consumen con mayor frecuencia y en qué equipos? ¿Qué técnicos resuelven más correctivos y en qué tiempo promedio? ¿Qué porcentaje de correctivos requirió escalamiento a un técnico externo? ¿Cuántas citas fueron canceladas o reprogramadas por fallas, y en qué área? ¿Qué equipos generan mayor costo acumulado respecto a su valor de adquisición? ¿Qué categoría presenta menor confiabilidad (mayor tasa de fallas por unidad de tiempo)?

## 17. Reglas de negocio

- Un área puede tener varias salas; una sala pertenece a una única área.
- Un equipo pertenece a una única sala en un momento dado, pero puede ser reubicado en el tiempo; cada reubicación queda registrada con sala anterior (nula solo en la primera ubicación) y sala nueva (siempre obligatoria y distinta de la anterior).
- Un equipo pertenece a una única categoría; una categoría pertenece a una única área.
- Un equipo puede tener varios planes de mantenimiento preventivo a lo largo de su vida útil; un plan puede tener varias ejecuciones.
- Un equipo puede generar varias incidencias; una incidencia corresponde a un único equipo.
- Una incidencia genera una parada de equipo; una ejecución de mantenimiento preventivo también puede genera una parada de equipo. Una parada de equipo proviene exclusivamente de una incidencia o de una ejecución preventiva, nunca de ambas ni de ninguna.
- Una parada de equipo puede requerir cero o un mantenimiento correctivo.
- Todo mantenimiento correctivo tiene un técnico interno obligatorio; el técnico externo solo se registra si el caso fue escalado.
- Una ejecución de mantenimiento preventivo y un mantenimiento correctivo pueden requerir cero, uno o varios repuestos; un repuesto puede usarse en muchas ejecuciones y correctivos distintos. Cada registro de uso pertenece exclusivamente a una ejecución preventiva o a un correctivo, nunca a ambos.
- Un técnico puede no estar asociado a ningún proveedor (técnico interno); un repuesto puede no tener todavía tiene un proveedor habitual asignado.
- Un proveedor puede estar asociado a varios técnicos externos y suministrar varios repuestos.
- Una parada de equipo puede afectar cero, una o varias citas.
- La información histórica (incidencias, paradas, mantenimientos, reubicaciones, reprogramaciones) no debe perderse al cambiar los datos actuales del equipo, la sala o el proveedor.
- El estado actual de un equipo debe poder determinarse a partir de su historial de incidencias y mantenimientos.
