USE gestion_mantenimiento_equipos;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DROP TABLE IF EXISTS #Tally;

------------------------------------------------------------
-- 0. LIMPIEZA DE DATOS (orden inverso de dependencias)
------------------------------------------------------------
BEGIN TRY
    BEGIN TRAN;
    DELETE FROM CUANTIFICACION_DE_REPUESTOS;
    DELETE FROM REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO;
    DELETE FROM MANTENIMIENTO_CORRECTIVO;
    DELETE FROM PARADA_DE_EQUIPO;
    DELETE FROM INCIDENCIA;
    DELETE FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO;
    DELETE FROM PLAN_MANTENIMIENTO_PREVENTIVO;
    DELETE FROM HISTORIAL_UBICACIONES_EQUIPO;
    DELETE FROM EQUIPO_MEDICO;
    DELETE FROM SALA;
    DELETE FROM REPUESTO;
    DELETE FROM TECNICO;
    DELETE FROM PROVEEDOR;
    DELETE FROM AREA;
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;

DECLARE @tabla SYSNAME, @sql NVARCHAR(400);
DECLARE cur_ident CURSOR LOCAL FAST_FORWARD FOR
SELECT t FROM (VALUES
    ('CUANTIFICACION_DE_REPUESTOS'),('REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO'),
    ('MANTENIMIENTO_CORRECTIVO'),('PARADA_DE_EQUIPO'),('INCIDENCIA'),
    ('EJECUCCION_MANTENIMIENTO_PREVENTIVO'),('PLAN_MANTENIMIENTO_PREVENTIVO'),
    ('HISTORIAL_UBICACIONES_EQUIPO'),('SALA'),('REPUESTO'),('TECNICO'),
    ('PROVEEDOR'),('AREA')
) v(t);
OPEN cur_ident;
FETCH NEXT FROM cur_ident INTO @tabla;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID(@tabla) AND last_value IS NOT NULL)
    BEGIN
        SET @sql = N'DBCC CHECKIDENT (' + QUOTENAME(@tabla,'''') + N', RESEED, 0) WITH NO_INFOMSGS;';
        EXEC sp_executesql @sql;
    END;
    FETCH NEXT FROM cur_ident INTO @tabla;
END;
CLOSE cur_ident;
DEALLOCATE cur_ident;

------------------------------------------------------------
-- 1. TABLA TALLY
------------------------------------------------------------
;WITH E1(n) AS (SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v(n)),
E2(n) AS (SELECT 1 FROM E1 a CROSS JOIN E1 b)
SELECT TOP (200) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
INTO #Tally
FROM E2 a CROSS JOIN E2 b;
CREATE UNIQUE CLUSTERED INDEX IX_Tally_n ON #Tally(n);

------------------------------------------------------------
-- 2. AREA
------------------------------------------------------------
INSERT INTO AREA (codigo, nombre) VALUES
('AR0001','Consultorios'),
('AR0002','Imagenes'),
('AR0003','Rehabilitacion');

------------------------------------------------------------
-- 3. PROVEEDOR
------------------------------------------------------------
INSERT INTO PROVEEDOR (codigo, razon_social, ruc, tiempo_de_respuesta) VALUES
('PR0001','ElectroMedical SAC','20451236789',4),
('PR0002','BioTec Service EIRL','20458965412',6),
('PR0003','Diagnostica Peru SAC','20478523691',3),
('PR0004','Rehab Equip SRL','20412365478',8),
('PR0005','Imagenes Medicas SAC','20465897123',5),
('PR0006','Repuestos Hospitalarios SAC','20423698741',2);

------------------------------------------------------------
-- 4. TECNICO 
------------------------------------------------------------
INSERT INTO TECNICO (codigo, nombre, especialidad, tipo, codigo_proveedor, estado) VALUES
('TC0001','Jorge Quispe Mamani','Electromedicina','interno',NULL,'activo'),
('TC0002','Maria Huaman Rojas','Imagenologia','interno',NULL,'activo'),
('TC0003','Luis Ccalla Ttito','Electromedicina','interno',NULL,'activo'),
('TC0004','Rosa Palomino Vera','Equipos de rehabilitacion','interno',NULL,'activo'),
('TC0005','Carlos Ramos Flores','Electromedicina','interno',NULL,'activo'),
('TC0006','Elena Mendoza Soto','Imagenologia','interno',NULL,'inactivo'),
('TC0007','Pedro Salas Diaz','Electromedicina','externo','PR0001','activo'),
('TC0008','Ines Chavez Gutierrez','Imagenologia','externo','PR0005','activo'),
('TC0009','Walter Fernandez Nina','Equipos de rehabilitacion','externo','PR0004','activo'),
('TC0010','Patricia Lopez Vargas','Electromedicina','externo','PR0002','activo');

------------------------------------------------------------
-- 5. REPUESTO 
------------------------------------------------------------
INSERT INTO REPUESTO (codigo, denominacion, codigo_proveedor, costo_unitario, stock_disponible, stock_minimo) VALUES
('RP0001','Bateria recargable 12V','PR0001',85.00,20,5),
('RP0002','Sensor de presion','PR0001',150.00,10,3),
('RP0003','Transductor de ecografia','PR0005',2500.00,3,1),
('RP0004','Tubo de rayos X','PR0005',8500.00,2,1),
('RP0005','Electrodo desechable (caja x50)','PR0003',35.00,40,10),
('RP0006','Filtro de aire','PR0002',25.00,30,8),
('RP0007','Cable de electrodo ECG','PR0003',60.00,15,5),
('RP0008','Manguito de presion adulto','PR0003',45.00,25,6),
('RP0009','Resistencia de calentamiento','PR0004',120.00,8,2),
('RP0010','Panel de control tactil','PR0002',650.00,4,1),
('RP0011','Fusible de proteccion','PR0006',8.00,100,20),
('RP0012','Correa de transmision','PR0004',55.00,2,3),
('RP0013','Lampara UV de repuesto','PR0004',95.00,10,3),
('RP0014','Bombillo de examen clinico','PR0003',18.00,30,8),
('RP0015','Bateria de respaldo UPS','PR0002',220.00,1,2);

------------------------------------------------------------
-- 6. SALA - 18 salas
------------------------------------------------------------
INSERT INTO SALA (codigo, codigo_area, ubicacion, estado) VALUES
('SA0001','AR0001','Piso 1 - Consultorio 1','activo'),
('SA0002','AR0001','Piso 1 - Consultorio 2','activo'),
('SA0003','AR0001','Piso 1 - Consultorio 3','activo'),
('SA0004','AR0001','Piso 1 - Consultorio 4','activo'),
('SA0005','AR0001','Piso 1 - Consultorio 5','activo'),
('SA0006','AR0001','Piso 1 - Consultorio 6','activo'),
('SA0007','AR0001','Piso 1 - Consultorio 7','activo'),
('SA0008','AR0001','Piso 1 - Consultorio 8','activo'),
('SA0009','AR0001','Piso 1 - Consultorio 9','activo'),
('SA0010','AR0002','Piso 1 - Sala de Ecografia 1','activo'),
('SA0011','AR0002','Piso 1 - Sala de Ecografia 2','activo'),
('SA0012','AR0002','Piso 1 - Sala de Rayos X','activo'),
('SA0013','AR0002','Piso 1 - Sala de Lectura','activo'),
('SA0014','AR0003','Piso 2 - Sala de Ejercicios de Fisioterapia 1','activo'),
('SA0015','AR0003','Piso 2 - Sala de Ejercicios de Fisioterapia 2','activo'),
('SA0016','AR0003','Piso 2 - Sala de Terapia Fisica 1','activo'),
('SA0017','AR0003','Piso 2 - Sala de Terapia Fisica 2','activo'),
('SA0018','AR0003','Piso 2 - Sala de Terapia Fisica 3','activo');

------------------------------------------------------------
-- 7. EQUIPO_MEDICO - 34 equipos
------------------------------------------------------------
INSERT INTO EQUIPO_MEDICO
(codigo_patrimonial, denominacion, marca, modelo, serie, categoria, codigo_sala,
 fecha_adquision, vida_util, precio_adquision, estado, criticidad)
VALUES
('EQ-0001','Tensiometro digital','Riester','RI-100','SN-0001','Tensiometro digital','SA0001','2021-03-10',8,350.00,'operativo','baja'),
('EQ-0002','Linterna de examen clinico','Welch Allyn','WA-10','SN-0002','Linterna de examen clinico','SA0001','2020-07-15',6,120.00,'operativo','baja'),
('EQ-0003','Tensiometro digital','Riester','RI-100','SN-0003','Tensiometro digital','SA0002','2021-03-10',8,350.00,'operativo','baja'),
('EQ-0004','Electrocardiografo','Mortara','ELI-150','SN-0004','Electrocardiografo','SA0002','2022-01-20',8,4200.00,'operativo','alta'),
('EQ-0005','Tensiometro digital','Riester','RI-100','SN-0005','Tensiometro digital','SA0003','2021-03-10',8,350.00,'operativo','baja'),
('EQ-0006','Balanza clinica','Detecto','DT-400','SN-0006','Balanza clinica','SA0003','2019-11-05',10,680.00,'operativo','media'),
('EQ-0007','Tensiometro digital','Riester','RI-100','SN-0007','Tensiometro digital','SA0004','2021-03-10',8,350.00,'operativo','baja'),
('EQ-0008','Martillo de reflejos','Riester','RI-05','SN-0008','Martillo de reflejos','SA0004','2020-02-18',10,45.00,'operativo','baja'),
('EQ-0009','Tensiometro digital','Riester','RI-100','SN-0009','Tensiometro digital','SA0005','2021-03-10',8,350.00,'operativo','baja'),
('EQ-0010','Pantoscopio','Welch Allyn','WA-PT2','SN-0010','Pantoscopio','SA0005','2018-09-12',8,310.00,'operativo','baja'),
('EQ-0011','Tensiometro digital','Riester','RI-100','SN-0011','Tensiometro digital','SA0006','2021-03-10',8,350.00,'operativo','baja'),
('EQ-0012','Lampara de examen clinico','Burton','BR-200','SN-0012','Lampara de examen clinico','SA0006','2021-06-01',7,290.00,'operativo','baja'),
('EQ-0013','Electrocardiografo','Mortara','ELI-150','SN-0013','Electrocardiografo','SA0007','2022-01-20',8,4200.00,'operativo','alta'),
('EQ-0014','Balanza clinica','Detecto','DT-400','SN-0014','Balanza clinica','SA0007','2019-11-05',10,680.00,'operativo','media'),
('EQ-0015','Linterna de examen clinico','Welch Allyn','WA-10','SN-0015','Linterna de examen clinico','SA0008','2020-07-15',6,120.00,'operativo','baja'),
('EQ-0016','Martillo de reflejos','Riester','RI-05','SN-0016','Martillo de reflejos','SA0008','2020-02-18',10,45.00,'operativo','baja'),
('EQ-0017','Balanza clinica','Detecto','DT-400','SN-0017','Balanza clinica','SA0009','2019-11-05',10,680.00,'operativo','media'),
('EQ-0018','Lampara de examen clinico','Burton','BR-200','SN-0018','Lampara de examen clinico','SA0009','2021-06-01',7,290.00,'operativo','baja'),
('EQ-0019','Ecografo estacionario','GE Healthcare','Voluson E8','SN-0019','Ecografo estacionario','SA0010','2020-05-14',10,95000.00,'operativo','alta'),
('EQ-0020','Ecografo estacionario','Philips','Affiniti 50','SN-0020','Ecografo estacionario','SA0011','2023-02-09',10,98000.00,'operativo','alta'),
('EQ-0021','Equipo de rayos X','GE Healthcare','Definium 6000','SN-0021','Equipo de rayos X','SA0012','2019-08-22',12,120000.00,'operativo','alta'),
('EQ-0022','Negatoscopio de 2 campos','Burton','NG-2C','SN-0022','Negatoscopio de 2 campos','SA0013','2020-01-11',10,520.00,'operativo','baja'),
('EQ-0023','Bicicleta ergometrica','BTL','BTL-6000','SN-0023','Bicicleta ergometrica','SA0014','2021-04-19',8,3200.00,'operativo','media'),
('EQ-0024','Bicicleta ergometrica','BTL','BTL-6000','SN-0024','Bicicleta ergometrica','SA0015','2021-04-19',8,3200.00,'operativo','media'),
('EQ-0025','Tanque de compresas calientes','Chattanooga','Hydrocollator E-2','SN-0025','Tanque de compresas calientes','SA0016','2019-12-07',10,1800.00,'operativo','media'),
('EQ-0026','Tanque de compresas frias','Chattanooga','Cold Pack Unit','SN-0026','Tanque de compresas frias','SA0016','2019-12-07',10,1500.00,'en_mantenimiento','media'),
('EQ-0027','Lampara de rayos ultravioleta','Chattanooga','UV-200','SN-0027','Lampara de rayos ultravioleta','SA0016','2020-09-25',7,2100.00,'operativo','media'),
('EQ-0028','Equipo de terapia de onda corta','BTL','BTL-4000 Premium','SN-0028','Equipo de terapia de onda corta','SA0017','2022-03-30',8,7600.00,'operativo','alta'),
('EQ-0029','Equipo de magnetoterapia','BTL','BTL-6000 SWT','SN-0029','Equipo de magnetoterapia','SA0017','2020-11-02',8,6200.00,'operativo','media'),
('EQ-0030','Estimulador nervioso transcutaneo','Chattanooga','Intelect TENS','SN-0030','Estimulador nervioso transcutaneo','SA0017','2022-05-28',6,980.00,'operativo','baja'),
('EQ-0031','Equipo de terapia con ultrasonido','Chattanooga','Intelect Mobile','SN-0031','Equipo de terapia con ultrasonido','SA0018','2021-07-17',8,5400.00,'operativo','alta'),
('EQ-0032','Equipo de terapia con ultrasonido','Chattanooga','Intelect Mobile','SN-0032','Equipo de terapia con ultrasonido','SA0018','2021-07-17',8,5400.00,'operativo','alta'),
('EQ-0033','Equipo de electroterapia','BTL','BTL-4625','SN-0033','Equipo de electroterapia','SA0018','2021-01-14',8,4800.00,'operativo','alta'),
('EQ-0034','Equipo de electroterapia','BTL','BTL-4625','SN-0034','Equipo de electroterapia','SA0018','2021-01-14',8,4800.00,'operativo','alta');

------------------------------------------------------------
-- 8. HISTORIAL_UBICACIONES_EQUIPO 
------------------------------------------------------------
INSERT INTO HISTORIAL_UBICACIONES_EQUIPO (codigo_equipo, codigo_sala_anterior, codigo_sala_actual, fecha_cambio, motivo) VALUES
('EQ-0007','SA0001','SA0004','2023-03-15','Redistribucion por alta demanda en consultorio 4'),
('EQ-0007','SA0004','SA0009','2023-10-15','Redistribucion por alta demanda en consultorio 9'),
('EQ-0007','SA0009','SA0005','2024-06-15','Redistribucion por alta demanda en consultorio 5'),
('EQ-0016','SA0004','SA0008','2024-01-10','Reubicacion por mantenimiento programado del consultorio 4'),
('EQ-0020','SA0010','SA0011','2023-11-20','Balanceo de carga entre salas de ecografia'),
('EQ-0024','SA0014','SA0015','2024-05-02','Division del gimnasio en dos salas de ejercicios'),
('EQ-0033','SA0016','SA0018','2024-09-01','Consolidacion de equipos de electroterapia en sala 3');

------------------------------------------------------------
-- 9. PLAN_MANTENIMIENTO_PREVENTIVO 
------------------------------------------------------------
INSERT INTO PLAN_MANTENIMIENTO_PREVENTIVO
(codigo, codigo_equipo, frecuencia, actividades, fecha_inicio, fecha_proxima_ejecuccion, costo_estimado, estado)
SELECT
    'PL' + RIGHT('0000' + CONVERT(VARCHAR(4), ROW_NUMBER() OVER (ORDER BY em.codigo_patrimonial)), 4),
    em.codigo_patrimonial,
    CASE
        WHEN em.categoria IN ('Ecografo estacionario','Equipo de rayos X') THEN 'trimestral'
        WHEN a.nombre = 'Consultorios' THEN 'mensual'
        WHEN a.nombre = 'Imagenes' THEN 'trimestral'
        ELSE 'semestral'
    END,
    'Limpieza, calibracion y revision tecnica general',
    DATEADD(MONTH, -(ROW_NUMBER() OVER (ORDER BY em.codigo_patrimonial) % 6), '2025-02-01'),
    NULL,
    CASE
        WHEN em.categoria IN ('Ecografo estacionario','Equipo de rayos X') THEN 450.00
        WHEN a.nombre = 'Rehabilitacion' THEN 150.00
        ELSE 80.00
    END,
    'activo'
FROM EQUIPO_MEDICO em
JOIN SALA s ON s.codigo = em.codigo_sala
JOIN AREA a ON a.codigo = s.codigo_area;
------------------------------------------------------------
-- 10. EJECUCCION_MANTENIMIENTO_PREVENTIVO 
------------------------------------------------------------
INSERT INTO EJECUCCION_MANTENIMIENTO_PREVENTIVO
(codigo_plan_mantenimiento, codigo_tecnico, fecha_ejecuccion, costo_real, hallazgos, estado)
SELECT
    p.codigo,
    tc.codigo,
    DATEADD(MINUTE, (p.id * 23 + t.n * 11) % 60,
        DATEADD(HOUR, 8 + (p.id + t.n) % 9,
            DATEADD(MONTH,
                -CASE p.frecuencia
                    WHEN 'mensual'    THEN (3 - t.n) * 1
                    WHEN 'trimestral' THEN (3 - t.n) * 3
                    WHEN 'semestral'  THEN (3 - t.n) * 6
                    ELSE                   (3 - t.n) * 12
                END,
                GETDATE()
            )
        )
    ) AS fecha_ejecuccion,
    CASE WHEN (p.id + t.n) % 10 < 8 THEN p.costo_estimado * (0.9 + ((p.id + t.n) % 3) * 0.1) ELSE NULL END,
    CASE WHEN (p.id + t.n) % 10 < 8 THEN 'Sin hallazgos relevantes' ELSE 'Reprogramado por indisponibilidad de sala' END,
    CASE
        WHEN (p.id + t.n) % 10 < 8 THEN 'realizado'
        WHEN (p.id + t.n) % 10 < 9 THEN 'reprogramado'
        ELSE 'no_realizado'
    END
FROM PLAN_MANTENIMIENTO_PREVENTIVO p
CROSS JOIN (SELECT TOP 2 n FROM #Tally ORDER BY n) t
JOIN TECNICO tc ON tc.id = 1 + ((p.id + t.n) % 6)
WHERE p.estado = 'activo'
ORDER BY p.id, t.n
OPTION (MAXDOP 1);

-- fecha_proxima_ejecuccion SI puede ser futura: es la cita pendiente
UPDATE p
SET fecha_proxima_ejecuccion =
    CASE p.frecuencia
        WHEN 'mensual'    THEN DATEADD(MONTH, 1, u.ultima)
        WHEN 'trimestral' THEN DATEADD(MONTH, 3, u.ultima)
        WHEN 'semestral'  THEN DATEADD(MONTH, 6, u.ultima)
        ELSE DATEADD(MONTH, 12, u.ultima)
    END
FROM PLAN_MANTENIMIENTO_PREVENTIVO p
CROSS APPLY (SELECT MAX(fecha_ejecuccion) AS ultima FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e WHERE e.codigo_plan_mantenimiento = p.codigo) u
WHERE u.ultima IS NOT NULL;

------------------------------------------------------------
-- 11. INCIDENCIA (con hora y minuto variables en fecha_de_reporte)
------------------------------------------------------------
;WITH Equipos AS
(
    SELECT codigo_patrimonial, ROW_NUMBER() OVER (ORDER BY codigo_patrimonial) AS rn
    FROM EQUIPO_MEDICO
),
ReportantesNum AS
(
    SELECT nombre, cargo, ROW_NUMBER() OVER (ORDER BY nombre) AS rn
    FROM (VALUES
        ('Ana Flores','Enfermera'),('Luis Torres','Tecnico de turno'),
        ('Rosa Medina','Medico'),('Carlos Vega','Recepcion'),
        ('Maria Rojas','Enfermera'),('Pedro Diaz','Medico'),
        ('Sofia Castro','Tecnico de turno'),('Jorge Luna','Recepcion')
    ) v(nombre, cargo)
),
FallasNum AS
(
    SELECT descripcion, ROW_NUMBER() OVER (ORDER BY descripcion) AS rn
    FROM (VALUES
        ('No enciende'),('Error de calibracion'),('Ruido anormal durante el uso'),
        ('Pantalla no responde'),('Falla de bateria'),('Fuga electrica detectada'),
        ('Imagen distorsionada'),('Se apaga solo durante el uso')
    ) v(descripcion)
),
EdadPorIncidencia AS
(
    SELECT
        t.n,
        CASE
            WHEN t.n <= 3  THEN 1 + (t.n - 1) * 2
            WHEN t.n <= 9  THEN 10 + (t.n - 4) * 4
            WHEN t.n <= 11 THEN 35 + (t.n - 10) * 20
            ELSE 65 + (t.n - 12) * 14
        END AS antiguedad_dias
    FROM (SELECT TOP 40 n FROM #Tally ORDER BY n) t
)
INSERT INTO INCIDENCIA (codigo_equipo, fecha_de_reporte, reportado_por, cargo, descripcion_falla, prioridad, estado)
SELECT
    e.codigo_patrimonial,
    DATEADD(MINUTE, (ep.n * 37) % 60,
        DATEADD(HOUR, 7 + (ep.n * 13) % 12,
            DATEADD(DAY, -ep.antiguedad_dias, GETDATE())
        )
    ) AS fecha_de_reporte,
    r.nombre,
    r.cargo,
    f.descripcion,
    CASE WHEN ep.n % 5 = 0 THEN 'urgente' WHEN ep.n % 5 IN (1,2) THEN 'media' ELSE 'baja' END,
    CASE
        WHEN ep.antiguedad_dias <= 7  THEN 'reportada'
        WHEN ep.antiguedad_dias <= 30 THEN 'en_atencion'
        WHEN ep.antiguedad_dias <= 60 THEN 'resuelta'
        ELSE 'cerrada'
    END AS estado
FROM EdadPorIncidencia ep
JOIN Equipos e ON e.rn = 1 + (ep.n % 34)
JOIN ReportantesNum r ON r.rn = 1 + (ep.n % 8)
JOIN FallasNum f ON f.rn = 1 + (ep.n % 8)
ORDER BY ep.n
OPTION (MAXDOP 1);

------------------------------------------------------------
-- 12. PARADA_DE_EQUIPO (programadas)
------------------------------------------------------------
INSERT INTO PARADA_DE_EQUIPO (id_incidencia, id_ejecuccion_mantenimiento_preventivo, tipo_parada, fecha_inicio, fecha_fin)
SELECT TOP 10
    NULL,
    e.id,
    'programada',
    CAST(e.fecha_ejecuccion AS DATETIME),
    DATEADD(HOUR, 3, CAST(e.fecha_ejecuccion AS DATETIME))
FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e
WHERE e.estado = 'realizado'
ORDER BY e.id;

------------------------------------------------------------
-- 13. CIERRE DE PARADAS (incidencias)
------------------------------------------------------------
UPDATE pe
SET fecha_fin = DATEADD(HOUR, 6 + (pe.id * 5) % 66, pe.fecha_inicio)
FROM PARADA_DE_EQUIPO pe
JOIN INCIDENCIA i ON i.id = pe.id_incidencia
WHERE pe.id_incidencia IS NOT NULL
  AND i.estado IN ('resuelta','cerrada');

------------------------------------------------------------
-- 14. ESTADO DEL EQUIPO 
------------------------------------------------------------
UPDATE em
SET estado = 'fuera_de_servicio'
FROM EQUIPO_MEDICO em
JOIN INCIDENCIA i ON i.codigo_equipo = em.codigo_patrimonial
JOIN PARADA_DE_EQUIPO pe ON pe.id_incidencia = i.id
WHERE pe.fecha_fin IS NULL
  AND em.estado = 'operativo';


------------------------------------------------------------
-- 16. MANTENIMIENTO_CORRECTIVO 
------------------------------------------------------------
-- Preventivos: entre 1 y 3 repuestos por ejecucion 'realizado'
INSERT INTO CUANTIFICACION_DE_REPUESTOS (id_ejecucion_mantenimiento_preventivo, id_mantenimiento_correctivo, codigo_repuesto, cantidad, costo_unitario)
SELECT
    e.id,
    NULL,
    r.codigo,
    1 + ((e.id + pos.n) % 3),
    r.costo_unitario
FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e
CROSS JOIN (SELECT TOP 3 n FROM #Tally ORDER BY n) pos   -- posiciones 1, 2, 3
JOIN REPUESTO r ON r.id = 1 + ((e.id + pos.n * 5) % 15)
WHERE e.estado = 'realizado'
  AND pos.n <= (1 + (e.id % 3))   -- e.id%3=0 -> 1 repuesto; =1 -> 2 repuestos; =2 -> 3 repuestos
ORDER BY e.id, pos.n;

-- Correctivos: entre 1 y 2 repuestos por correctivo (excepto 'pendiente', que aun no usa nada)
INSERT INTO CUANTIFICACION_DE_REPUESTOS (id_ejecucion_mantenimiento_preventivo, id_mantenimiento_correctivo, codigo_repuesto, cantidad, costo_unitario)
SELECT
    NULL,
    mc.id,
    r.codigo,
    1 + ((mc.id + pos.n) % 2),
    r.costo_unitario
FROM MANTENIMIENTO_CORRECTIVO mc
CROSS JOIN (SELECT TOP 2 n FROM #Tally ORDER BY n) pos   -- posiciones 1, 2
JOIN REPUESTO r ON r.id = 1 + ((mc.id + pos.n * 7) % 15)
WHERE mc.estado <> 'pendiente'
  AND pos.n <= (1 + (mc.id % 2))   -- mc.id%2=0 -> 1 repuesto; =1 -> 2 repuestos
ORDER BY mc.id, pos.n;

------------------------------------------------------------
-- 17. REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO 
------------------------------------------------------------
;WITH ParadaSala AS
(
    SELECT
        pe.id AS id_parada,
        pe.fecha_inicio,
        pe.fecha_fin,
        COALESCE(em_i.codigo_sala, em_e.codigo_sala) AS codigo_sala
    FROM PARADA_DE_EQUIPO pe
    LEFT JOIN INCIDENCIA i ON i.id = pe.id_incidencia
    LEFT JOIN EQUIPO_MEDICO em_i ON em_i.codigo_patrimonial = i.codigo_equipo
    LEFT JOIN EJECUCCION_MANTENIMIENTO_PREVENTIVO e ON e.id = pe.id_ejecuccion_mantenimiento_preventivo
    LEFT JOIN PLAN_MANTENIMIENTO_PREVENTIVO pl ON pl.codigo = e.codigo_plan_mantenimiento
    LEFT JOIN EQUIPO_MEDICO em_e ON em_e.codigo_patrimonial = pl.codigo_equipo
    WHERE pe.fecha_fin IS NOT NULL
),
ParadaConHora AS
(
    SELECT
        ps.*,
        DATEADD(
            MINUTE,
            (DATEDIFF(MINUTE, ps.fecha_inicio, ps.fecha_fin) * ((ps.id_parada % 5) * 20)) / 100,
            ps.fecha_inicio
        ) AS punto_dentro,
        DATEDIFF(MINUTE, ps.fecha_inicio, ps.fecha_fin) AS duracion_minutos
    FROM ParadaSala ps
),
ParadaRedondeada AS
(
    SELECT
        id_parada,
        codigo_sala,
        fecha_inicio,
        fecha_fin,
        DATEADD(MINUTE, -(DATEPART(MINUTE, punto_dentro) % 20), punto_dentro) AS fecha_original
    FROM ParadaConHora
    WHERE duracion_minutos >= 20
)
INSERT INTO REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO (id_parada, codigo_sala, fecha_original, fecha_nueva)
SELECT
    id_parada,
    codigo_sala,
    fecha_original,
    CASE
        WHEN id_parada % 3 = 0 THEN NULL
        ELSE
            DATEADD(MINUTE, ((id_parada + 1) % 3) * 20,
                DATEADD(HOUR, 8 + ((id_parada + 1) % 9),
                    CAST(CAST(DATEADD(DAY, 1, fecha_fin) AS DATE) AS DATETIME)
                )
            )
    END AS fecha_nueva
FROM ParadaRedondeada
WHERE fecha_original BETWEEN fecha_inicio AND fecha_fin
ORDER BY id_parada;

------------------------------------------------------------
-- 18. CUANTIFICACION_DE_REPUESTOS 
------------------------------------------------------------
INSERT INTO CUANTIFICACION_DE_REPUESTOS (id_ejecucion_mantenimiento_preventivo, id_mantenimiento_correctivo, codigo_repuesto, cantidad, costo_unitario)
SELECT TOP 15
    e.id, NULL,
    r.codigo,
    1 + (e.id % 3),
    r.costo_unitario
FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO e
JOIN REPUESTO r ON r.id = 1 + (e.id % 15)
WHERE e.estado = 'realizado'
ORDER BY e.id;

INSERT INTO CUANTIFICACION_DE_REPUESTOS (id_ejecucion_mantenimiento_preventivo, id_mantenimiento_correctivo, codigo_repuesto, cantidad, costo_unitario)
SELECT TOP 18
    NULL, mc.id,
    r.codigo,
    1 + (mc.id % 2),
    r.costo_unitario
FROM MANTENIMIENTO_CORRECTIVO mc
JOIN REPUESTO r ON r.id = 1 + (mc.id % 15)
ORDER BY mc.id;

------------------------------------------------------------
-- 19. LIMPIEZA Y VALIDACIONES
------------------------------------------------------------
DROP TABLE IF EXISTS #Tally;

SELECT 'AREA' tabla, COUNT(*) cantidad FROM AREA
UNION ALL SELECT 'PROVEEDOR', COUNT(*) FROM PROVEEDOR
UNION ALL SELECT 'TECNICO', COUNT(*) FROM TECNICO
UNION ALL SELECT 'REPUESTO', COUNT(*) FROM REPUESTO
UNION ALL SELECT 'SALA', COUNT(*) FROM SALA
UNION ALL SELECT 'EQUIPO_MEDICO', COUNT(*) FROM EQUIPO_MEDICO
UNION ALL SELECT 'HISTORIAL_UBICACIONES_EQUIPO', COUNT(*) FROM HISTORIAL_UBICACIONES_EQUIPO
UNION ALL SELECT 'PLAN_MANTENIMIENTO_PREVENTIVO', COUNT(*) FROM PLAN_MANTENIMIENTO_PREVENTIVO
UNION ALL SELECT 'EJECUCCION_MANTENIMIENTO_PREVENTIVO', COUNT(*) FROM EJECUCCION_MANTENIMIENTO_PREVENTIVO
UNION ALL SELECT 'INCIDENCIA', COUNT(*) FROM INCIDENCIA
UNION ALL SELECT 'PARADA_DE_EQUIPO', COUNT(*) FROM PARADA_DE_EQUIPO
UNION ALL SELECT 'MANTENIMIENTO_CORRECTIVO', COUNT(*) FROM MANTENIMIENTO_CORRECTIVO
UNION ALL SELECT 'REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO', COUNT(*) FROM REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO
UNION ALL SELECT 'CUANTIFICACION_DE_REPUESTOS', COUNT(*) FROM CUANTIFICACION_DE_REPUESTOS;

-- Verifica que cada consultorio tenga minimo 2 equipos (debe dar 9 filas, todas >= 2)
SELECT s.codigo, s.ubicacion, COUNT(em.codigo_patrimonial) AS equipos
FROM SALA s
JOIN EQUIPO_MEDICO em ON em.codigo_sala = s.codigo
WHERE s.codigo_area = 'AR0001'
GROUP BY s.codigo, s.ubicacion
ORDER BY s.codigo;

-- Verifica exclusividad de origen en PARADA_DE_EQUIPO (debe dar 0)
SELECT COUNT(*) AS paradas_invalidas
FROM PARADA_DE_EQUIPO
WHERE (id_incidencia IS NULL AND id_ejecuccion_mantenimiento_preventivo IS NULL)
   OR (id_incidencia IS NOT NULL AND id_ejecuccion_mantenimiento_preventivo IS NOT NULL);

-- Verifica que el tecnico interno/externo del correctivo tenga el tipo correcto (debe dar 0)
SELECT COUNT(*) AS correctivos_invalidos
FROM MANTENIMIENTO_CORRECTIVO mc
JOIN TECNICO ti ON ti.codigo = mc.codigo_tecnico_interno
LEFT JOIN TECNICO te ON te.codigo = mc.codigo_tecnico_externo
WHERE ti.tipo <> 'interno'
   OR (mc.codigo_tecnico_externo IS NOT NULL AND te.tipo <> 'externo');

-- Verifica que ningun tecnico interno tenga proveedor y que todo externo si lo tenga (debe dar 0)
SELECT COUNT(*) AS tecnicos_invalidos
FROM TECNICO
WHERE (tipo = 'interno' AND codigo_proveedor IS NOT NULL)
   OR (tipo = 'externo' AND codigo_proveedor IS NULL);