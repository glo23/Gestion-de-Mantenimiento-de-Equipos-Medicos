CREATE DATABASE gestion_mantenimiento_equipos;
GO

USE gestion_mantenimiento_equipos;
GO

--- AREA

CREATE TABLE AREA (
	id INT IDENTITY(1,1) PRIMARY KEY,
	codigo CHAR(6) UNIQUE NOT NULL,
	nombre VARCHAR(100) NOT NULL
);

--- PROVEEDOR

CREATE TABLE PROVEEDOR (
	id INT IDENTITY(1,1) PRIMARY KEY,
	codigo CHAR(6) UNIQUE NOT NULL,
	razon_social VARCHAR(255) NOT NULL UNIQUE,
	ruc CHAR(11) NOT NULL UNIQUE,
	tiempo_de_respuesta INT NULL
);

--- TECNICO
--- (1) se agregó "estado"; (4) se agregó CHECK cruzando tipo <-> id_proveedor

CREATE TABLE TECNICO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	codigo CHAR(6) UNIQUE NOT NULL,
	nombre VARCHAR(155) NOT NULL,
	especialidad VARCHAR(100) NULL,
	tipo VARCHAR(20) NOT NULL,
	id_proveedor INT NULL,
	estado VARCHAR(25) NOT NULL,
	CONSTRAINT FK_tecnico_proveedor FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id),
	CONSTRAINT CK_tecnico_tipo CHECK (tipo IN ('interno','externo')),
	CONSTRAINT CK_tecnico_estado CHECK (estado IN ('activo','inactivo')),
	CONSTRAINT CK_tecnico_proveedor_segun_tipo CHECK (
		(tipo = 'interno' AND id_proveedor IS NULL)
		OR (tipo = 'externo' AND id_proveedor IS NOT NULL)
	)
);

--- REPUESTO

CREATE TABLE REPUESTO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	codigo CHAR(6) UNIQUE NOT NULL,
	denominacion VARCHAR(255) NOT NULL,
	id_proveedor INT NULL,
	costo_unitario DECIMAL(12,2) NOT NULL,
	stock_disponible INT NOT NULL DEFAULT 0,
	stock_minimo INT NOT NULL DEFAULT 0,
	CONSTRAINT FK_repuesto_proveedor FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id)
);

--- SALA

CREATE TABLE SALA (
	id INT IDENTITY(1,1) PRIMARY KEY,
	codigo CHAR(6) UNIQUE NOT NULL,
	id_area INT NOT NULL,
	ubicacion VARCHAR(100) NULL,
	estado VARCHAR(25) NOT NULL,
	CONSTRAINT FK_sala_area FOREIGN KEY (id_area) REFERENCES AREA(id),
	CONSTRAINT CK_sala_estado CHECK (estado IN ('activo','en_mantenimiento','inactivo'))
);

--- EQUIPO_MEDICO
--- (ya tenía su código de negocio: codigo_patrimonial)

CREATE TABLE EQUIPO_MEDICO (
	codigo_patrimonial VARCHAR(20) PRIMARY KEY,
	denominacion VARCHAR(155) NOT NULL,
	marca VARCHAR(100) NULL,
	modelo VARCHAR(100) NULL,
	serie VARCHAR(100) NULL,
	categoria VARCHAR(100) NOT NULL,
	id_sala INT NOT NULL,
	fecha_adquision DATE NOT NULL,
	vida_util INT NULL,
	precio_adquision DECIMAL(12,2) NULL,
	estado VARCHAR(25) NOT NULL,
	criticidad VARCHAR(10) NOT NULL,
	CONSTRAINT FK_equipo_sala FOREIGN KEY (id_sala) REFERENCES SALA(id),
	CONSTRAINT CK_equipo_estado CHECK (estado IN ('operativo','en_mantenimiento','fuera_de_servicio','de_baja')),
	CONSTRAINT CK_equipo_criticidad CHECK (criticidad IN ('alta','media','baja'))
);

--- PLAN_MANTENIMIENTO_PREVENTIVO
--- (7) se agregó "codigo"

CREATE TABLE PLAN_MANTENIMIENTO_PREVENTIVO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	codigo CHAR(6) UNIQUE NOT NULL,
	id_equipo VARCHAR(20) NOT NULL,
	frecuencia VARCHAR(20) NOT NULL,
	actividades VARCHAR(500) NULL,
	fecha_inicio DATE NOT NULL,
	fecha_proxima_ejecuccion DATE NULL,
	costo_estimado DECIMAL(12,2) NULL,
	estado VARCHAR(25) NOT NULL,
	CONSTRAINT FK_plan_equipo FOREIGN KEY (id_equipo) REFERENCES EQUIPO_MEDICO(codigo_patrimonial),
	CONSTRAINT CK_plan_frecuencia CHECK (frecuencia IN ('mensual','trimestral','semestral','anual')),
	CONSTRAINT CK_plan_estado CHECK (estado IN ('activo','suspendido'))
);

--- EJECUCCION_MANTENIMIENTO_PREVENTIVO
--- (3) costo_total -> costo_real, para que coincida con el texto ("costo real")

CREATE TABLE EJECUCCION_MANTENIMIENTO_PREVENTIVO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_plan_mantenimiento INT NOT NULL,
	id_tecnico INT NOT NULL,
	fecha_ejecuccion DATE NOT NULL,
	costo_real DECIMAL(12,2) NULL,
	hallazgos VARCHAR(500) NULL,
	estado VARCHAR(25) NOT NULL,
	CONSTRAINT FK_ejecuccion_plan FOREIGN KEY (id_plan_mantenimiento) REFERENCES PLAN_MANTENIMIENTO_PREVENTIVO(id),
	CONSTRAINT FK_ejecuccion_tecnico FOREIGN KEY (id_tecnico) REFERENCES TECNICO(id),
	CONSTRAINT CK_ejecuccion_estado CHECK (estado IN ('realizado','reprogramado','no_realizado'))
);

--- INCIDENCIA
--- (2) prioridad ahora es categórica, no INT libre

CREATE TABLE INCIDENCIA (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_equipo VARCHAR(20) NOT NULL,
	fecha_de_reporte DATETIME NOT NULL,
	reportado_por VARCHAR(155) NULL,
	cargo VARCHAR(100) NULL,
	descripcion_falla VARCHAR(500) NOT NULL,
	prioridad VARCHAR(20) NOT NULL,
	estado VARCHAR(25) NOT NULL,
	CONSTRAINT FK_incidencia_equipo FOREIGN KEY (id_equipo) REFERENCES EQUIPO_MEDICO(codigo_patrimonial),
	CONSTRAINT CK_incidencia_prioridad CHECK (prioridad IN ('urgente','media','baja')),
	CONSTRAINT CK_incidencia_estado CHECK (estado IN ('reportada','en_atencion','resuelta','cerrada'))
);

--- PARADA_DE_EQUIPO

CREATE TABLE PARADA_DE_EQUIPO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_incidencia INT NULL,
	id_ejecuccion_mantenimiento_preventivo INT NULL,
	tipo_parada VARCHAR(20) NOT NULL,
	fecha_inicio DATETIME NOT NULL,
	fecha_fin DATETIME NULL,
	CONSTRAINT FK_parada_incidencia FOREIGN KEY (id_incidencia) REFERENCES INCIDENCIA(id),
	CONSTRAINT FK_parada_ejecuccion FOREIGN KEY (id_ejecuccion_mantenimiento_preventivo) REFERENCES EJECUCCION_MANTENIMIENTO_PREVENTIVO(id),
	CONSTRAINT CK_parada_tipo CHECK (tipo_parada IN ('programada','no_programada')),
	CONSTRAINT CK_parada_origen_exclusivo CHECK (
		(id_incidencia IS NOT NULL AND id_ejecuccion_mantenimiento_preventivo IS NULL)
		OR
		(id_incidencia IS NULL AND id_ejecuccion_mantenimiento_preventivo IS NOT NULL)
	)
);
GO

-- Un solo índice único por cada origen (permite NULLs libres, solo exige
-- unicidad entre los valores NO nulos) -> garantiza que cada incidencia
-- y cada ejecución tengan, como máximo, UNA parada asociada.
CREATE UNIQUE INDEX UQ_parada_incidencia
	ON PARADA_DE_EQUIPO(id_incidencia) WHERE id_incidencia IS NOT NULL;

CREATE UNIQUE INDEX UQ_parada_ejecuccion
	ON PARADA_DE_EQUIPO(id_ejecuccion_mantenimiento_preventivo) WHERE id_ejecuccion_mantenimiento_preventivo IS NOT NULL;
GO

--- MANTENIMIENTO_CORRECTIVO

CREATE TABLE MANTENIMIENTO_CORRECTIVO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_parada INT NOT NULL UNIQUE,
	id_tecnico_interno INT NOT NULL,
	id_tecnico_externo INT NULL,
	acciones VARCHAR(500) NULL,
	fecha_atencion DATETIME NULL,
	costo_total DECIMAL(12,2) NULL,
	estado VARCHAR(25) NOT NULL,
	CONSTRAINT FK_correctivo_parada FOREIGN KEY (id_parada) REFERENCES PARADA_DE_EQUIPO(id),
	CONSTRAINT FK_correctivo_tecnico_interno FOREIGN KEY (id_tecnico_interno) REFERENCES TECNICO(id),
	CONSTRAINT FK_correctivo_tecnico_externo FOREIGN KEY (id_tecnico_externo) REFERENCES TECNICO(id),
	CONSTRAINT CK_correctivo_estado CHECK (estado IN ('en_atencion','resuelto','cerrado'))
);

--- REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO

CREATE TABLE REPROGRAMACION_CITA_POR_PARADA_DE_EQUIPO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_parada INT NOT NULL,
	id_sala INT NOT NULL,
	fecha_original DATETIME NOT NULL,
	fecha_nueva DATETIME NULL,
	CONSTRAINT FK_reprog_parada FOREIGN KEY (id_parada) REFERENCES PARADA_DE_EQUIPO(id),
	CONSTRAINT FK_reprog_sala FOREIGN KEY (id_sala) REFERENCES SALA(id)
);

--- HISTORIAL_UBICACIONES_EQUIPO

CREATE TABLE HISTORIAL_UBICACIONES_EQUIPO (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_equipo VARCHAR(20) NOT NULL,
	id_sala_anterior INT NULL,
	id_sala_actual INT NOT NULL,
	fecha_cambio DATE NOT NULL,
	motivo VARCHAR(255) NULL,
	CONSTRAINT FK_historial_equipo FOREIGN KEY (id_equipo) REFERENCES EQUIPO_MEDICO(codigo_patrimonial),
	CONSTRAINT FK_historial_sala_anterior FOREIGN KEY (id_sala_anterior) REFERENCES SALA(id),
	CONSTRAINT FK_historial_sala_actual FOREIGN KEY (id_sala_actual) REFERENCES SALA(id),
	CONSTRAINT CK_historial_salas_distintas CHECK (id_sala_anterior IS NULL OR id_sala_anterior <> id_sala_actual)
);

--- CUANTIFICACION_DE_REPUESTOS

CREATE TABLE CUANTIFICACION_DE_REPUESTOS (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_ejecucion_mantenimiento_preventivo INT NULL,
	id_mantenimiento_correctivo INT NULL,
	id_repuesto INT NOT NULL,
	cantidad INT NOT NULL,
	costo_unitario DECIMAL(12,2) NOT NULL,
	CONSTRAINT FK_cuant_ejecuccion FOREIGN KEY (id_ejecucion_mantenimiento_preventivo) REFERENCES EJECUCCION_MANTENIMIENTO_PREVENTIVO(id),
	CONSTRAINT FK_cuant_correctivo FOREIGN KEY (id_mantenimiento_correctivo) REFERENCES MANTENIMIENTO_CORRECTIVO(id),
	CONSTRAINT FK_cuant_repuesto FOREIGN KEY (id_repuesto) REFERENCES REPUESTO(id),
	CONSTRAINT CK_cuant_cantidad CHECK (cantidad > 0),
	CONSTRAINT CK_cuant_origen_exclusivo CHECK (
		(id_ejecucion_mantenimiento_preventivo IS NOT NULL AND id_mantenimiento_correctivo IS NULL)
		OR
		(id_ejecucion_mantenimiento_preventivo IS NULL AND id_mantenimiento_correctivo IS NOT NULL)
	)
);
GO

-- (6) TRIGGER: toda incidencia GENERA automáticamente su parada de equipo
-- (relación obligatoria 1:1 real, no solo documentada)

CREATE TRIGGER TRG_incidencia_genera_parada
ON INCIDENCIA
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO PARADA_DE_EQUIPO (id_incidencia, id_ejecuccion_mantenimiento_preventivo, tipo_parada, fecha_inicio, fecha_fin)
	SELECT
		i.id,
		NULL,
		'no_programada',
		i.fecha_de_reporte,
		NULL
	FROM inserted i;
END;
GO