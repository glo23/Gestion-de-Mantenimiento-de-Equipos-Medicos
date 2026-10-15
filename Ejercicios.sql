USE gestion_mantenimiento_equipos;

/* PREGUNTA 1: ¿Qué equipos están operativos y cuáles fuera de servicio? */

/*tabla resumen */
SELECT 
    a.nombre AS servicio,
    em.estado,
    COUNT(*) AS cantidad
FROM EQUIPO_MEDICO em
JOIN VW_EQUIPO_UBICACION_ACTUAL v ON v.codigo_equipo = em.codigo_patrimonial
JOIN SALA s ON s.codigo = v.codigo_sala
JOIN AREA a ON a.codigo = s.codigo_area
GROUP BY a.nombre, em.estado
ORDER BY 
    a.nombre,
    CASE em.estado
        WHEN 'operativo' THEN 1
        WHEN 'en_mantenimiento' THEN 2
        WHEN 'fuera_de_servicio' THEN 3
        WHEN 'de_baja' THEN 4
    END;

/*tabla detalle de fuera_de_servicio y de_baja */
SELECT 
    a.nombre AS servicio,
    em.estado,
    em.codigo_patrimonial AS codigo,
    v.codigo_sala AS sala,
    em.denominacion AS equipo
FROM EQUIPO_MEDICO em
JOIN VW_EQUIPO_UBICACION_ACTUAL v ON v.codigo_equipo = em.codigo_patrimonial
JOIN SALA s ON s.codigo = v.codigo_sala
JOIN AREA a ON a.codigo = s.codigo_area
WHERE em.estado IN ('fuera_de_servicio', 'de_baja')
ORDER BY 
    a.nombre,
    CASE em.estado
        WHEN 'fuera_de_servicio' THEN 1
        WHEN 'de_baja' THEN 2
    END

/* PREGUNTA 2: ¿Qué área presenta mayor frecuencia de fallas? */

/* INDICADOR: PROMEDIO DE INCIDENCIAS POR AÑO CALCULADO POR INCIDENCIAS TOTAL DEL EQUIPO/ AÑOS EN EL SERVICIO */

DROP TABLE IF EXISTS #EquipoTasa;

;WITH Base AS (
    SELECT
        em.codigo_patrimonial,
        em.denominacion,
        v.codigo_sala,
        a.nombre AS area,
        COUNT(i.id) AS cantidad_incidencias,
        CAST(DATEDIFF(DAY, em.fecha_adquision, GETDATE()) AS DECIMAL(10,2)) / 365 AS anios_en_servicio
    FROM EQUIPO_MEDICO em
    JOIN VW_EQUIPO_UBICACION_ACTUAL v ON v.codigo_equipo = em.codigo_patrimonial
    JOIN SALA s ON s.codigo = v.codigo_sala
    JOIN AREA a ON a.codigo = s.codigo_area
    LEFT JOIN INCIDENCIA i ON i.codigo_equipo = em.codigo_patrimonial
    WHERE em.estado <> 'de_baja'
    GROUP BY em.codigo_patrimonial, em.denominacion, v.codigo_sala, a.nombre, em.fecha_adquision
)
SELECT *,
    CAST(cantidad_incidencias AS DECIMAL(10,2)) / NULLIF(anios_en_servicio, 0) AS tasa_anual
INTO #EquipoTasa
FROM Base;

DECLARE @promedio_general DECIMAL(10,4) = (SELECT AVG(tasa_anual) FROM #EquipoTasa);

/* tabla 1 resumen */

SELECT
    area,
    COUNT(*) AS cantidad_equipos,
    SUM(cantidad_incidencias) AS total_incidencias,
    CAST(AVG(tasa_anual) AS DECIMAL(10,2)) AS promedio_incidencias_por_anio,
    CASE
        WHEN AVG(tasa_anual) <= @promedio_general THEN 'Normal'
        WHEN AVG(tasa_anual) <= @promedio_general * 2 THEN 'Frecuente'
        ELSE 'Muy frecuente'
    END AS clasificacion
FROM #EquipoTasa
GROUP BY area
ORDER BY promedio_incidencias_por_anio DESC;

/* tabla 2 detalle por equipo */
SELECT
    area,
    codigo_sala AS sala,
    codigo_patrimonial AS codigo,
    denominacion AS equipo,
    cantidad_incidencias,
    CAST(anios_en_servicio AS DECIMAL(10,1)) AS anios_en_servicio,
    CAST(tasa_anual AS DECIMAL(10,2)) AS incidencias_por_anio,
    CASE
        WHEN tasa_anual <= @promedio_general THEN 'Normal'
        WHEN tasa_anual <= @promedio_general * 2 THEN 'Frecuente'
        ELSE 'Muy frecuente'
    END AS clasificacion
FROM #EquipoTasa
ORDER BY area, tasa_anual DESC;

/* PREGUNTA 3: ¿Se cumple el cronograma de mantenimiento preventivo? */

WITH UltimoCiclo AS (
    SELECT 
        p.codigo_equipo,
        e.estado,
        ROW_NUMBER() OVER (PARTITION BY e.codigo_plan_mantenimiento ORDER BY e.fecha_programada DESC) AS rn
    FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e
    JOIN PLAN_MANTENIMIENTO_PREVENTIVO p ON p.codigo = e.codigo_plan_mantenimiento
),
PorEquipo AS (
    SELECT
        em.codigo_patrimonial,
        em.denominacion,
        COUNT(*) AS total_ciclos,
        SUM(CASE WHEN e.estado = 'realizado' THEN 1 ELSE 0 END) AS realizados,
        SUM(CASE WHEN e.estado = 'reprogramado' THEN 1 ELSE 0 END) AS reprogramados,
        SUM(CASE WHEN e.estado = 'no_realizado' THEN 1 ELSE 0 END) AS no_realizados,
        CAST(100.0 * SUM(CASE WHEN e.estado = 'realizado' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,2)) AS pct_realizados,
        CAST(100.0 * SUM(CASE WHEN e.estado = 'reprogramado' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,2)) AS pct_reprogramados,
        CAST(100.0 * SUM(CASE WHEN e.estado = 'no_realizado' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,2)) AS pct_no_realizados,
        CAST(AVG(CASE WHEN e.estado = 'realizado' 
                  THEN CAST(DATEDIFF(DAY, e.fecha_programada, e.fecha_ejecuccion) AS DECIMAL(10,2)) 
                  END) AS DECIMAL(10,2)) AS dias_desfase_equipo,
        CASE WHEN EXISTS (
            SELECT 1 FROM UltimoCiclo u WHERE u.codigo_equipo = em.codigo_patrimonial AND u.rn = 1 AND u.estado <> 'realizado'
        ) THEN 1 ELSE 0 END AS tiene_pendiente_actual
    FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e
    JOIN PLAN_MANTENIMIENTO_PREVENTIVO p ON p.codigo = e.codigo_plan_mantenimiento
    JOIN EQUIPO_MEDICO em ON em.codigo_patrimonial = p.codigo_equipo
    GROUP BY em.codigo_patrimonial, em.denominacion
)
SELECT
    pe.denominacion AS equipo,
    COUNT(*) AS equipos_totales,
    CAST(AVG(pe.pct_realizados) AS DECIMAL(10,1)) AS realizados_pct_promedio,
    CAST(AVG(pe.pct_reprogramados) AS DECIMAL(10,1)) AS reprogramados_pct_promedio,
    CAST(AVG(pe.pct_no_realizados) AS DECIMAL(10,1)) AS no_realizados_pct_promedio,
    SUM(pe.tiene_pendiente_actual) AS equipos_con_pendiente_actual,
    CAST(AVG(pe.dias_desfase_equipo) AS DECIMAL(10,1)) AS dias_desfasados_promedio
FROM PorEquipo pe
GROUP BY pe.denominacion
ORDER BY realizados_pct_promedio ASC;

/* PREGUNTA 4: ¿Qué proveedores responden con mayor rapidez? */

WITH Interno AS (
    SELECT id_mantenimiento_correctivo, fecha_atencion AS fecha_interno
    FROM ATENCION_CORRECTIVO
    WHERE orden = 1
),
PrimerExterno AS (
    SELECT id_mantenimiento_correctivo, fecha_atencion AS fecha_primer_externo, codigo_tecnico
    FROM ATENCION_CORRECTIVO
    WHERE orden = 2
),
Cierre AS (
    SELECT id_mantenimiento_correctivo, MAX(fecha_atencion) AS fecha_cierre
    FROM ATENCION_CORRECTIVO
    WHERE resultado = 'resuelto'
    GROUP BY id_mantenimiento_correctivo
),
VisitasPorCaso AS (
    SELECT id_mantenimiento_correctivo, COUNT(*) AS visitas_requeridas
    FROM ATENCION_CORRECTIVO
    GROUP BY id_mantenimiento_correctivo
),
Base AS (
    SELECT
        em.criticidad,
        pr.razon_social AS proveedor,
        pr.tiempo_de_respuesta,
        i.fecha_interno,
        pe.fecha_primer_externo,
        c.fecha_cierre,
        v.visitas_requeridas
    FROM PrimerExterno pe
    JOIN Interno i ON i.id_mantenimiento_correctivo = pe.id_mantenimiento_correctivo
    JOIN MANTENIMIENTO_CORRECTIVO mc ON mc.id = pe.id_mantenimiento_correctivo
    JOIN PARADA_DE_EQUIPO par ON par.id = mc.id_parada
    JOIN INCIDENCIA inc ON inc.id = par.id_incidencia
    JOIN EQUIPO_MEDICO em ON em.codigo_patrimonial = inc.codigo_equipo
    JOIN TECNICO te ON te.codigo = pe.codigo_tecnico
    JOIN PROVEEDOR pr ON pr.codigo = te.codigo_proveedor
    LEFT JOIN Cierre c ON c.id_mantenimiento_correctivo = pe.id_mantenimiento_correctivo
    JOIN VisitasPorCaso v ON v.id_mantenimiento_correctivo = pe.id_mantenimiento_correctivo
)
SELECT
    criticidad,
    proveedor,
    tiempo_de_respuesta,
    COUNT(*) AS incidencias_atendidas,
    CAST(AVG(CAST(DATEDIFF(MINUTE, fecha_interno, fecha_primer_externo) AS DECIMAL(10,2)) / 60.0) AS DECIMAL(10,1)) AS horas_hasta_primera_revision,
    CAST(AVG(CAST(DATEDIFF(MINUTE, fecha_primer_externo, fecha_cierre) AS DECIMAL(10,2)) / 60.0) AS DECIMAL(10,1)) AS horas_hasta_cierre_total,
    CAST(AVG(CAST(visitas_requeridas AS DECIMAL(10,2))) AS DECIMAL(10,1)) AS visitas_requeridas_promedio
FROM Base
GROUP BY criticidad, proveedor, tiempo_de_respuesta
ORDER BY criticidad, horas_hasta_primera_revision ASC;

/* PREGUNTA 5: ¿Cuánto cuesta mantener cada equipo en el tiempo? */

DROP TABLE IF EXISTS #CostoConAnio;

WITH CostosPreventivo AS (
    SELECT
        p.codigo_equipo,
        e.costo_real AS costo,
        e.fecha_ejecuccion AS fecha_costo,
        'preventivo' AS tipo_mantenimiento
    FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e
    JOIN PLAN_MANTENIMIENTO_PREVENTIVO p ON p.codigo = e.codigo_plan_mantenimiento
    WHERE e.estado = 'realizado'
),
CostosCorrectivo AS (
    SELECT
        inc.codigo_equipo,
        mc.costo_total AS costo,
        a.fecha_atencion AS fecha_costo,
        'correctivo' AS tipo_mantenimiento
    FROM ATENCION_CORRECTIVO a
    JOIN MANTENIMIENTO_CORRECTIVO mc ON mc.id = a.id_mantenimiento_correctivo
    JOIN PARADA_DE_EQUIPO par ON par.id = mc.id_parada
    JOIN INCIDENCIA inc ON inc.id = par.id_incidencia
    WHERE a.resultado = 'resuelto'
      AND mc.costo_total IS NOT NULL
),
TodosLosCostos AS (
    SELECT * FROM CostosPreventivo
    UNION ALL
    SELECT * FROM CostosCorrectivo
)
SELECT
    em.codigo_patrimonial,
    em.denominacion,
    tc.costo,
    tc.tipo_mantenimiento,
    DATEDIFF(DAY, em.fecha_adquision, tc.fecha_costo) / 365 + 1 AS anio_de_vida
INTO #CostoConAnio
FROM TodosLosCostos tc
JOIN EQUIPO_MEDICO em ON em.codigo_patrimonial = tc.codigo_equipo
WHERE tc.fecha_costo >= em.fecha_adquision;

SELECT
    denominacion AS equipo,
    anio_de_vida,
    COUNT(DISTINCT codigo_patrimonial) AS equipos_con_este_nombre,
    SUM(CASE WHEN tipo_mantenimiento = 'preventivo' THEN 1 ELSE 0 END) AS eventos_preventivo,
    SUM(CASE WHEN tipo_mantenimiento = 'correctivo' THEN 1 ELSE 0 END) AS eventos_correctivo,
    CAST(SUM(CASE WHEN tipo_mantenimiento = 'preventivo' THEN costo ELSE 0 END) AS DECIMAL(12,2)) AS costo_total_preventivo,
    CAST(SUM(CASE WHEN tipo_mantenimiento = 'correctivo' THEN costo ELSE 0 END) AS DECIMAL(12,2)) AS costo_total_correctivo,
    CAST(SUM(costo) AS DECIMAL(12,2)) AS costo_total_anio,
    CAST(SUM(costo) / COUNT(DISTINCT codigo_patrimonial) AS DECIMAL(12,2)) AS costo_total_anio_promedio,
    CAST(
        100.0 * (SUM(costo) - LAG(SUM(costo)) OVER (PARTITION BY denominacion ORDER BY anio_de_vida))
        / NULLIF(LAG(SUM(costo)) OVER (PARTITION BY denominacion ORDER BY anio_de_vida), 0)
    AS DECIMAL(10,1)) AS variacion_pct_vs_anio_anterior
FROM #CostoConAnio
GROUP BY denominacion, anio_de_vida
ORDER BY denominacion, anio_de_vida;

/* PREGUNTA 6: ¿Cuántas citas se vieron afectadas por indisponibilidad de equipos? */

WITH CitasAfectadas AS (
    SELECT
        r.id_parada,
        r.codigo_sala,
        r.fecha_original,
        r.fecha_nueva,
        CASE WHEN r.fecha_nueva IS NULL THEN 'cancelada' ELSE 'reprogramada' END AS estado_cita,
        COALESCE(em_i.codigo_patrimonial, em_e.codigo_patrimonial) AS codigo_equipo,
        COALESCE(em_i.denominacion, em_e.denominacion) AS equipo
    FROM REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO r
    JOIN PARADA_DE_EQUIPO pe ON pe.id = r.id_parada
    LEFT JOIN INCIDENCIA i ON i.id = pe.id_incidencia
    LEFT JOIN EQUIPO_MEDICO em_i ON em_i.codigo_patrimonial = i.codigo_equipo
    LEFT JOIN EJECUCCION_MANTENIMIENTO_PREVENTIVO e ON e.id = pe.id_ejecuccion_mantenimiento_preventivo
    LEFT JOIN PLAN_MANTENIMIENTO_PREVENTIVO pl ON pl.codigo = e.codigo_plan_mantenimiento
    LEFT JOIN EQUIPO_MEDICO em_e ON em_e.codigo_patrimonial = pl.codigo_equipo
)

/* Tabla 1: por area */

SELECT
    a.nombre AS area,
    COUNT(*) AS citas_afectadas,
    SUM(CASE WHEN c.estado_cita = 'reprogramada' THEN 1 ELSE 0 END) AS reprogramadas,
    SUM(CASE WHEN c.estado_cita = 'cancelada' THEN 1 ELSE 0 END) AS canceladas,
    CAST(100.0 * SUM(CASE WHEN c.estado_cita = 'cancelada' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,1)) AS pct_canceladas
FROM CitasAfectadas c
JOIN SALA s ON s.codigo = c.codigo_sala
JOIN AREA a ON a.codigo = s.codigo_area
GROUP BY a.nombre

UNION ALL

SELECT
    'TOTAL GENERAL',
    COUNT(*),
    SUM(CASE WHEN estado_cita = 'reprogramada' THEN 1 ELSE 0 END),
    SUM(CASE WHEN estado_cita = 'cancelada' THEN 1 ELSE 0 END),
    CAST(100.0 * SUM(CASE WHEN estado_cita = 'cancelada' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,1))
FROM CitasAfectadas;


/* Tabla 2: evolucion por año */

WITH CitasAfectadas2 AS (
    SELECT
        r.fecha_original,
        CASE WHEN r.fecha_nueva IS NULL THEN 'cancelada' ELSE 'reprogramada' END AS estado_cita
    FROM REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO r
)
SELECT
    YEAR(fecha_original) AS anio,
    COUNT(*) AS citas_afectadas,
    SUM(CASE WHEN estado_cita = 'reprogramada' THEN 1 ELSE 0 END) AS reprogramadas,
    SUM(CASE WHEN estado_cita = 'cancelada' THEN 1 ELSE 0 END) AS canceladas,
    CAST(100.0 * SUM(CASE WHEN estado_cita = 'cancelada' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,1)) AS pct_canceladas
FROM CitasAfectadas2
GROUP BY YEAR(fecha_original)
ORDER BY anio;


/* PREGUNTA 7: ¿Cómo evoluciona la confiabilidad de un equipo? */

WITH IncidenciasEquipo AS (
    SELECT
        i.id,
        i.codigo_equipo,
        i.fecha_de_reporte,
        LAG(i.fecha_de_reporte) OVER (PARTITION BY i.codigo_equipo ORDER BY i.fecha_de_reporte) AS fecha_incidencia_anterior
    FROM INCIDENCIA i
),
IncidenciasConAnio AS (
    SELECT
        ie.codigo_equipo,
        em.denominacion,
        DATEDIFF(DAY, ie.fecha_incidencia_anterior, ie.fecha_de_reporte) AS dias_desde_anterior,
        DATEDIFF(DAY, em.fecha_adquision, ie.fecha_de_reporte) / 365 + 1 AS anio_de_vida,
        pe.fecha_inicio,
        pe.fecha_fin
    FROM IncidenciasEquipo ie
    JOIN EQUIPO_MEDICO em ON em.codigo_patrimonial = ie.codigo_equipo
    LEFT JOIN PARADA_DE_EQUIPO pe ON pe.id_incidencia = ie.id
),
PorAnio AS (
    SELECT
        codigo_equipo,
        denominacion,
        anio_de_vida,
        COUNT(*) AS cantidad_incidencias,
        /* MTBF (tiempo promedio entre fallas */
        CAST(AVG(CAST(dias_desde_anterior AS DECIMAL(10,2))) AS DECIMAL(10,1)) AS mtbf_dias_promedio,
        /* Equipo en horas que no estuvo disponible */ 
        CAST(SUM(CASE WHEN fecha_fin IS NOT NULL THEN DATEDIFF(MINUTE, fecha_inicio, fecha_fin) ELSE 0 END) / 60.0 AS DECIMAL(10,1)) AS horas_indisponible
    FROM IncidenciasConAnio
    GROUP BY codigo_equipo, denominacion, anio_de_vida
)
SELECT
    codigo_equipo AS codigo,
    denominacion AS equipo,
    anio_de_vida,
    cantidad_incidencias,
    mtbf_dias_promedio,
    horas_indisponible,
    CASE 
        WHEN LAG(cantidad_incidencias) OVER (PARTITION BY codigo_equipo ORDER BY anio_de_vida) IS NULL THEN NULL
        WHEN cantidad_incidencias > LAG(cantidad_incidencias) OVER (PARTITION BY codigo_equipo ORDER BY anio_de_vida) THEN 'Empeorando'
        WHEN cantidad_incidencias < LAG(cantidad_incidencias) OVER (PARTITION BY codigo_equipo ORDER BY anio_de_vida) THEN 'Mejorando'
        ELSE 'Estable'
    END AS tendencia
FROM PorAnio
ORDER BY codigo_equipo, anio_de_vida;