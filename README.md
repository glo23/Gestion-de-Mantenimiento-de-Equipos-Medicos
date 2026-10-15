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

Identificador interno, código patrimonial único, denominación, categoría (define a qué área da soporte: diagnóstico, imágenes o rehabilitación), marca, modelo, número de serie, fecha de adquisición, vida útil estimada, valor de adquisición, estado actual (operativo / en mantenimiento / fuera de servicio / de baja) y criticidad (alta / media / baja).

La sala donde se encuentra el equipo no se almacena directamente en esta entidad — se obtiene siempre a partir de su historial de ubicaciones (ver sección 4), tomando el registro más reciente. Esto evita mantener el mismo dato en dos lugares distintos y obliga a que todo cambio de sala quede registrado como un evento de historial.

**Categorías por área:**

- **Diagnóstico**: tensiómetros, linterna de examen clínico, electrocardiógrafos, balanzas, martillo de reflejos, pantoscopio, lámpara de examen clínico.
- **Imágenes**: ecógrafo estacionario, equipo de rayos X, negatoscopio de 2 campos.
- **Rehabilitación**: bicicleta ergométrica, tanque de compresas calientes, tanque de compresas frías, lámpara de rayos ultravioleta, equipo de terapia de onda corta, equipo de terapia con ultrasonido, equipo de magnetoterapia, estimulador nervioso transcutáneo, equipo de electroterapia.

## 4. Historial de ubicaciones de equipo

Equipo, sala anterior (vacía si es la primera ubicación del equipo), sala nueva (siempre obligatoria y distinta de la anterior), fecha del cambio y motivo. Registra cada reubicación de un equipo entre salas, incluso entre áreas distintas.

Esta entidad es la única fuente de la ubicación de un equipo, tanto histórica como actual: la sala donde está un equipo hoy se determina leyendo el registro más reciente de su historial, no una columna aparte. Por eso, dar de alta un equipo nuevo requiere registrar también su primera ubicación aquí (con sala anterior vacía), aunque todavía no se haya movido nunca.

## 5. Plan de mantenimiento preventivo

Equipo asociado, frecuencia (mensual, trimestral, semestral, anual), actividades a realizar, fecha de inicio, fecha programada de la próxima ejecución, costo estimado y estado (activo / suspendido). Un equipo puede tener varios planes a lo largo de su vida útil.

## 6. Ejecución de mantenimiento preventivo

Plan al que corresponde, técnico asignado, fecha programada del ciclo, fecha real de ejecución, hallazgos, costo real y estado (realizado / reprogramado / no realizado).

La fecha programada siempre existe, para cualquier estado — es la fecha en que le tocaba ejecutarse a ese ciclo. La fecha real de ejecución solo existe cuando el estado es "realizado"; si el ciclo quedó reprogramado o no se realizó, este campo permanece vacío, ya que no hubo una ejecución real que registrar. Un plan puede tener varias ejecuciones a lo largo del tiempo.

## 7. Incidencia

Equipo afectado, fecha y hora de reporte, persona que reporta, cargo de quien reporta, descripción de la falla, prioridad (urgente / media / baja) y estado (reportada / en atención / resuelta / cerrada). Un equipo puede tener varias incidencias; una incidencia corresponde a un único equipo.

## 8. Parada de equipo

Tipo de parada (programada / no programada), fecha/hora de inicio y fecha/hora de fin. Se origina exclusivamente por una **incidencia** o por una **ejecución de mantenimiento preventivo** (nunca por ambas a la vez ni por ninguna), lo que permite tratar de forma unificada tanto las paradas imprevistas como las programadas.

## 9. Mantenimiento correctivo

Parada de equipo asociada (una por correctivo), costo total acumulado de la reparación y estado general del caso (pendiente / en atención / resuelto). Si el estado es "pendiente", el costo total permanece vacío, ya que el correctivo aún no ha sido atendido por nadie.

Esta entidad representa el caso en su conjunto — cuántas veces se visitó el equipo y quién lo atendió en cada una se registra por separado (ver sección 10), porque un mismo correctivo puede requerir más de una visita antes de quedar resuelto.

## 10. Atención de mantenimiento correctivo

Correctivo al que pertenece, número de orden de la visita (1, 2, 3...), técnico que atendió, fecha de la visita, acciones realizadas y resultado de esa visita (resuelto / escalado).

Un mismo correctivo puede tener varias atenciones, en orden:

- La primera visita (orden 1) siempre es de un técnico interno — es quien revisa el caso primero.
- Si el técnico interno no resuelve la falla (resultado = "escalado"), se registra una segunda visita de un técnico externo.
- Si ese técnico externo tampoco resuelve a la primera (resultado = "escalado"), puede haber una tercera visita — siempre de un técnico del mismo proveedor que atendió la visita anterior, nunca de un proveedor distinto, ya que el caso no cambia de empresa a mitad de camino.
- El correctivo queda cerrado cuando alguna visita registra resultado = "resuelto".

## 11. Repuesto

Código, descripción, proveedor habitual, costo unitario, stock disponible y stock mínimo (para alertas de reposición).

## 12. Cuantificación de repuestos

Ejecución preventiva o mantenimiento correctivo al que pertenece (exclusivamente uno de los dos), repuesto utilizado, cantidad y costo unitario en ese momento. Registra cada uso individual de un repuesto, tanto en mantenimientos preventivos como correctivos.

## 13. Proveedor

Código, razón social, RUC y tiempo de respuesta contractual.

## 14. Técnico

Código, nombre completo, especialidad (electromedicina, imagenología, equipos de rehabilitación, etc.), tipo (interno / externo), proveedor al que pertenece (si es externo) y estado (activo / inactivo). Un técnico interno no está asociado a ningún proveedor.

## 15. Reprogramación de cita por parada de equipo

Parada relacionada, sala, fecha y hora original de la cita, y fecha y hora nueva (si fue reprogramada; si quedó cancelada, este campo permanece vacío). Una parada de equipo puede afectar cero, una o varias citas. Solo se registra una reprogramación cuando la parada ya tiene fecha de fin definida; mientras el equipo siga fuera de servicio, las citas afectadas quedan pendientes de reprogramar.

## 16. Información temporal

El modelo debe permitir analizar fallas, mantenimientos y disponibilidad por período: día, semana, mes, trimestre, año.

También debe permitir seguir la evolución de: incidencias por equipo, categoría y área; cumplimiento del mantenimiento preventivo; tiempo de indisponibilidad por sala y área; costos de mantenimiento; consumo de repuestos; y desempeño de proveedores y técnicos.

## 17. Requerimientos de análisis

Las 7 preguntas planteadas en el contexto del negocio ya cuentan con una solución SQL implementada:

**¿Qué equipos están operativos y cuáles fuera de servicio?**
Tabla resumen por servicio (área) y estado, con el conteo de equipos en cada combinación. Tabla de detalle filtrada a los estados "fuera de servicio" y "de baja", mostrando código, sala y nombre del equipo.

**¿Qué área presenta mayor frecuencia de fallas?**
Indicador de tasa anual de incidencias (incidencias totales del equipo ÷ años en servicio desde su adquisición), que normaliza la comparación entre equipos nuevos y antiguos. Clasificación en "Normal", "Frecuente" o "Muy frecuente" según el promedio general de la base. Tabla resumen por área y tabla de detalle por equipo.

**¿Se cumple el cronograma de mantenimiento preventivo?**
Agrupado por nombre de equipo: porcentaje de ciclos realizados, reprogramados y no realizados; cantidad de equipos con un ciclo pendiente actualmente sin resolver; y promedio de días de desfase entre la fecha programada y la fecha real de ejecución.

**¿Qué proveedores responden con mayor rapidez?**
Desglosado por criticidad del equipo: horas transcurridas desde que el técnico interno escaló el caso hasta que llegó el primer técnico externo; horas totales hasta el cierre del caso; y promedio de visitas requeridas por proveedor antes de resolver.

**¿Cuánto cuesta mantener cada equipo en el tiempo?**
Resumen por nombre de equipo y año de vida (año 1 = primeros 365 días desde la adquisición, y así sucesivamente): cantidad de eventos y costo total separados entre mantenimiento preventivo y correctivo, costo total promedio por unidad, y variación porcentual respecto al año anterior.

**¿Cuántas citas se vieron afectadas por indisponibilidad de equipos?**
Tabla por área con la cantidad de citas reprogramadas y canceladas, y el porcentaje de cancelación. Segunda tabla con la misma métrica desglosada año por año, para ver si el impacto en la atención a pacientes ha ido subiendo o bajando con el tiempo.

**¿Cómo evoluciona la confiabilidad de un equipo?**
Por año de vida del equipo: cantidad de incidencias, tiempo promedio entre fallas (MTBF) y horas de indisponibilidad acumuladas. Clasificación de tendencia año a año ("Mejorando" / "Empeorando" / "Estable"), y una tabla adicional que aísla los equipos con dos o más años consecutivos empeorando — la señal de que el deterioro es real y no una mala racha aislada.

## 18. Reglas de negocio

- Un área puede tener varias salas; una sala pertenece a una única área.
- Un equipo pertenece a una única sala en un momento dado, pero esa sala se determina a partir de su historial de ubicaciones, no se almacena directamente en el equipo. Cada reubicación queda registrada con sala anterior (nula solo en la primera ubicación) y sala nueva (siempre obligatoria y distinta de la anterior).
- Un equipo pertenece a una única categoría; una categoría pertenece a una única área.
- Un equipo puede tener varios planes de mantenimiento preventivo a lo largo de su vida útil; un plan puede tener varias ejecuciones.
- Cada ejecución de mantenimiento preventivo siempre tiene una fecha programada; solo tiene fecha real de ejecución si su estado es "realizado".
- Un equipo puede generar varias incidencias; una incidencia corresponde a un único equipo.
- Una incidencia genera una parada de equipo; una ejecución de mantenimiento preventivo también puede generar una parada de equipo. Una parada de equipo proviene exclusivamente de una incidencia o de una ejecución preventiva, nunca de ambas ni de ninguna.
- Una parada de equipo puede requerir cero o un mantenimiento correctivo.
- Un mantenimiento correctivo puede requerir una o varias atenciones (visitas). La primera atención siempre es de un técnico interno; si este escala el caso, las atenciones siguientes son de técnicos externos, y todos los técnicos externos de un mismo correctivo deben pertenecer al mismo proveedor.
- Una ejecución de mantenimiento preventivo y un mantenimiento correctivo pueden requerir cero, uno o varios repuestos; un repuesto puede usarse en muchas ejecuciones y correctivos distintos. Cada registro de uso pertenece exclusivamente a una ejecución preventiva o a un correctivo, nunca a ambos.
- Un técnico puede no estar asociado a ningún proveedor (técnico interno); un repuesto puede no tener todavía un proveedor habitual asignado.
- Un proveedor puede estar asociado a varios técnicos externos y suministrar varios repuestos.
- Una parada de equipo puede afectar cero, una o varias citas.
- La información histórica (incidencias, paradas, mantenimientos, atenciones, reubicaciones, reprogramaciones) no debe perderse al cambiar los datos actuales del equipo, la sala o el proveedor.
- El estado actual de un equipo debe poder determinarse a partir de su historial de incidencias y mantenimientos.
