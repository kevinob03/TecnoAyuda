-- ================================================================
-- TECNOAYUDA | ENTREGA COMPLETA BUSINESS SOLUTIONS (PARTE A)
-- Compatible con MySQL Server 8.0.16 o posterior.
-- Contiene: BD, 15 tablas, datos ficticios y consultas de metricas.
-- Los nombres coinciden con el diagrama ER y el Paso 3.
-- TODOS LOS DATOS SON INVENTADOS CON FINES ACADEMICOS.
-- ================================================================
-- SEGURIDAD:
-- Este archivo utiliza la base AISLADA `tecnoayuda_entrega`.
-- NO modifica ni elimina la base anterior `tecnoayuda`.
-- Al ejecutarlo nuevamente, se BORRARA y RECREARA solamente
-- `tecnoayuda_entrega`, incluyendo sus datos anteriores.
-- No lo uses dentro de una base con informacion real.
-- En Workbench: File > Open SQL Script; luego ejecuta TODO.
-- ================================================================

DROP DATABASE IF EXISTS tecnoayuda_entrega;
CREATE DATABASE tecnoayuda_entrega
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tecnoayuda_entrega;

-- ================================================================
-- PARTE 1. ESTRUCTURA: 15 TABLAS (DDL)
-- ================================================================

-- 1. Empleados
CREATE TABLE empleados (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(150) NOT NULL UNIQUE,
  rol VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- 2. Servicios
CREATE TABLE servicios (
  id_servicio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion VARCHAR(500),
  precio_base DECIMAL(12,2) NOT NULL,
  CONSTRAINT chk_servicios_precio CHECK (precio_base >= 0)
) ENGINE=InnoDB;

-- 3. Canales
CREATE TABLE canales (
  id_canal INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  tipo VARCHAR(10) NOT NULL,
  CONSTRAINT chk_canales_tipo CHECK (tipo IN ('Organico','Pagado'))
) ENGINE=InnoDB;

-- 4. Campanas (sin acentos en el nombre de la tabla para simplificar SQL)
CREATE TABLE campanas (
  id_campana INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  objetivo VARCHAR(500) NOT NULL,
  etapa_recorrido VARCHAR(20) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  presupuesto_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT chk_campanas_etapa CHECK (etapa_recorrido IN ('Conciencia','Consideracion','Decision')),
  CONSTRAINT chk_campanas_fecha CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT chk_campanas_presupuesto CHECK (presupuesto_total >= 0)
) ENGINE=InnoDB;

-- 5. Asignaciones de presupuesto
CREATE TABLE asignaciones_presupuesto (
  id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
  id_campana INT NOT NULL,
  id_canal INT NOT NULL,
  monto_asignado DECIMAL(12,2) NOT NULL,
  criterio VARCHAR(500) NOT NULL,
  CONSTRAINT chk_asignacion_monto CHECK (monto_asignado >= 0),
  CONSTRAINT fk_asignacion_campana FOREIGN KEY (id_campana) REFERENCES campanas(id_campana),
  CONSTRAINT fk_asignacion_canal FOREIGN KEY (id_canal) REFERENCES canales(id_canal),
  CONSTRAINT uq_asignacion_campana_canal UNIQUE (id_campana,id_canal)
) ENGINE=InnoDB;

-- 6. Contenidos
CREATE TABLE contenidos (
  id_contenido INT AUTO_INCREMENT PRIMARY KEY,
  id_campana INT NOT NULL,
  id_canal INT NOT NULL,
  id_autor INT NOT NULL,
  titulo VARCHAR(160) NOT NULL,
  tipo_contenido VARCHAR(50) NOT NULL,
  etapa_recorrido VARCHAR(20) NOT NULL,
  fecha_programada DATE NOT NULL,
  fecha_publicacion DATE,
  estado VARCHAR(20) NOT NULL DEFAULT 'Borrador',
  CONSTRAINT chk_contenido_etapa CHECK (etapa_recorrido IN ('Conciencia','Consideracion','Decision')),
  CONSTRAINT chk_contenido_estado CHECK (estado IN ('Borrador','En revision','Aprobado','Rechazado','Publicado')),
  CONSTRAINT fk_contenido_campana FOREIGN KEY (id_campana) REFERENCES campanas(id_campana),
  CONSTRAINT fk_contenido_canal FOREIGN KEY (id_canal) REFERENCES canales(id_canal),
  CONSTRAINT fk_contenido_autor FOREIGN KEY (id_autor) REFERENCES empleados(id_empleado)
) ENGINE=InnoDB;

-- 7. Revisiones de contenido
CREATE TABLE revisiones_contenido (
  id_revision INT AUTO_INCREMENT PRIMARY KEY,
  id_contenido INT NOT NULL,
  id_revisor INT NOT NULL,
  fecha_revision DATETIME NOT NULL,
  decision VARCHAR(10) NOT NULL,
  comentario VARCHAR(500),
  CONSTRAINT chk_revision_decision CHECK (decision IN ('Aprobado','Rechazado')),
  CONSTRAINT fk_revision_contenido FOREIGN KEY (id_contenido) REFERENCES contenidos(id_contenido),
  CONSTRAINT fk_revision_revisor FOREIGN KEY (id_revisor) REFERENCES empleados(id_empleado)
) ENGINE=InnoDB;

-- 8. Contactos
CREATE TABLE contactos (
  id_contacto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  empresa VARCHAR(120),
  correo VARCHAR(150) NOT NULL UNIQUE,
  telefono VARCHAR(30),
  fecha_registro DATETIME NOT NULL,
  etapa_recorrido VARCHAR(20) NOT NULL,
  id_campana_origen INT,
  id_canal_origen INT,
  CONSTRAINT chk_contacto_etapa CHECK (etapa_recorrido IN ('Conciencia','Consideracion','Decision')),
  CONSTRAINT fk_contacto_campana FOREIGN KEY (id_campana_origen) REFERENCES campanas(id_campana),
  CONSTRAINT fk_contacto_canal FOREIGN KEY (id_canal_origen) REFERENCES canales(id_canal)
) ENGINE=InnoDB;

-- 9. Historial del embudo
CREATE TABLE historial_embudo (
  id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
  id_contacto INT NOT NULL,
  etapa_embudo VARCHAR(20) NOT NULL,
  fecha_movimiento DATETIME NOT NULL,
  CONSTRAINT chk_historial_etapa CHECK (etapa_embudo IN ('Lead','Prospecto','Oportunidad','Cierre')),
  CONSTRAINT fk_historial_contacto FOREIGN KEY (id_contacto) REFERENCES contactos(id_contacto)
) ENGINE=InnoDB;

-- 10. Interacciones con contenido
CREATE TABLE interacciones_contenido (
  id_interaccion INT AUTO_INCREMENT PRIMARY KEY,
  id_contacto INT NOT NULL,
  id_contenido INT NOT NULL,
  tipo_interaccion VARCHAR(50) NOT NULL,
  fecha_interaccion DATETIME NOT NULL,
  CONSTRAINT fk_interaccion_contacto FOREIGN KEY (id_contacto) REFERENCES contactos(id_contacto),
  CONSTRAINT fk_interaccion_contenido FOREIGN KEY (id_contenido) REFERENCES contenidos(id_contenido)
) ENGINE=InnoDB;

-- 11. Traspasos a ventas
CREATE TABLE traspasos_ventas (
  id_traspaso INT AUTO_INCREMENT PRIMARY KEY,
  id_contacto INT NOT NULL,
  id_entrega INT NOT NULL,
  id_recibe INT NOT NULL,
  fecha_traspaso DATETIME NOT NULL,
  puntuacion INT NOT NULL,
  necesidad VARCHAR(500) NOT NULL,
  presupuesto_declarado DECIMAL(12,2),
  resumen_contenidos VARCHAR(500),
  notas VARCHAR(1000),
  estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
  fecha_respuesta DATETIME,
  motivo_rechazo VARCHAR(500),
  CONSTRAINT chk_traspaso_puntuacion CHECK (puntuacion BETWEEN 0 AND 100),
  CONSTRAINT chk_traspaso_presupuesto CHECK (presupuesto_declarado IS NULL OR presupuesto_declarado >= 0),
  CONSTRAINT chk_traspaso_estado CHECK (estado IN ('Pendiente','Aceptado','Rechazado')),
  CONSTRAINT fk_traspaso_contacto FOREIGN KEY (id_contacto) REFERENCES contactos(id_contacto),
  CONSTRAINT fk_traspaso_entrega FOREIGN KEY (id_entrega) REFERENCES empleados(id_empleado),
  CONSTRAINT fk_traspaso_recibe FOREIGN KEY (id_recibe) REFERENCES empleados(id_empleado)
) ENGINE=InnoDB;

-- 12. Oportunidades de venta
CREATE TABLE oportunidades_venta (
  id_oportunidad INT AUTO_INCREMENT PRIMARY KEY,
  id_contacto INT NOT NULL,
  id_servicio INT NOT NULL,
  id_vendedor INT NOT NULL,
  fecha_propuesta DATE NOT NULL,
  monto_estimado DECIMAL(12,2) NOT NULL,
  estado VARCHAR(20) NOT NULL,
  CONSTRAINT chk_oportunidad_monto CHECK (monto_estimado >= 0),
  CONSTRAINT chk_oportunidad_estado CHECK (estado IN ('Abierta','Ganada','Perdida')),
  CONSTRAINT fk_oportunidad_contacto FOREIGN KEY (id_contacto) REFERENCES contactos(id_contacto),
  CONSTRAINT fk_oportunidad_servicio FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio),
  CONSTRAINT fk_oportunidad_vendedor FOREIGN KEY (id_vendedor) REFERENCES empleados(id_empleado)
) ENGINE=InnoDB;

-- 13. Contratos
CREATE TABLE contratos (
  id_contrato INT AUTO_INCREMENT PRIMARY KEY,
  id_oportunidad INT NOT NULL UNIQUE,
  fecha_firma DATE NOT NULL,
  monto_final DECIMAL(12,2) NOT NULL,
  CONSTRAINT chk_contrato_monto CHECK (monto_final >= 0),
  CONSTRAINT fk_contrato_oportunidad FOREIGN KEY (id_oportunidad) REFERENCES oportunidades_venta(id_oportunidad)
) ENGINE=InnoDB;

-- 14. Gastos
CREATE TABLE gastos (
  id_gasto INT AUTO_INCREMENT PRIMARY KEY,
  id_campana INT,
  id_canal INT,
  categoria_gasto VARCHAR(50) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha_gasto DATE NOT NULL,
  CONSTRAINT chk_gasto_monto CHECK (monto >= 0),
  CONSTRAINT fk_gasto_campana FOREIGN KEY (id_campana) REFERENCES campanas(id_campana),
  CONSTRAINT fk_gasto_canal FOREIGN KEY (id_canal) REFERENCES canales(id_canal)
) ENGINE=InnoDB;

-- 15. Resultados de campana
CREATE TABLE resultados_campana (
  id_resultado INT AUTO_INCREMENT PRIMARY KEY,
  id_campana INT NOT NULL,
  id_canal INT NOT NULL,
  fecha DATE NOT NULL,
  impresiones INT NOT NULL DEFAULT 0,
  clics INT NOT NULL DEFAULT 0,
  me_gusta INT NOT NULL DEFAULT 0,
  visualizaciones INT NOT NULL DEFAULT 0,
  seguidores_nuevos INT NOT NULL DEFAULT 0,
  CONSTRAINT chk_resultados_no_negativos CHECK (
    impresiones >= 0 AND clics >= 0 AND me_gusta >= 0
    AND visualizaciones >= 0 AND seguidores_nuevos >= 0
  ),
  CONSTRAINT chk_resultados_clics CHECK (clics <= impresiones),
  CONSTRAINT fk_resultado_campana FOREIGN KEY (id_campana) REFERENCES campanas(id_campana),
  CONSTRAINT fk_resultado_canal FOREIGN KEY (id_canal) REFERENCES canales(id_canal),
  CONSTRAINT uq_resultado_fecha UNIQUE (id_campana,id_canal,fecha)
) ENGINE=InnoDB;

-- ================================================================
-- PARTE 2. DATOS FICTICIOS (DML)
-- Catalogos: minimo 5 filas por tabla.
-- Movimientos: minimo 10 filas por tabla.
-- ================================================================

-- CATALOGO 1: Empleados (6 registros)
INSERT INTO empleados (nombre, correo, rol) VALUES
  ('Ana Mora', 'ana@tecnoayuda.ejemplo', 'Mercadeo'),
  ('Luis Solano', 'luis@tecnoayuda.ejemplo', 'Mercadeo'),
  ('Valeria Ruiz', 'valeria@tecnoayuda.ejemplo', 'Gerencia'),
  ('Diego Rojas', 'diego@tecnoayuda.ejemplo', 'Ventas'),
  ('Sofia Vargas', 'sofia@tecnoayuda.ejemplo', 'Ventas'),
  ('Marco Campos', 'marco@tecnoayuda.ejemplo', 'Finanzas');

-- CATALOGO 2: Servicios (6 registros)
INSERT INTO servicios (nombre, descripcion, precio_base) VALUES
  ('Mantenimiento preventivo', 'Mantenimiento de equipos de una oficina.', 120000),
  ('Reparacion de computadoras', 'Diagnostico y reparacion de computadoras.', 180000),
  ('Instalacion de software', 'Instalacion y configuracion de programas.', 95000),
  ('Configuracion de redes', 'Instalacion y configuracion de red empresarial.', 250000),
  ('Soporte remoto mensual', 'Atencion y soporte a distancia por un mes.', 160000),
  ('Respaldo y seguridad', 'Copias de seguridad y proteccion de informacion.', 300000);

-- CATALOGO 3: Canales (6 registros)
INSERT INTO canales (nombre, tipo) VALUES
  ('Facebook', 'Organico'),
  ('Instagram', 'Organico'),
  ('Sitio web', 'Organico'),
  ('Google Ads', 'Pagado'),
  ('Meta Ads', 'Pagado'),
  ('Recomendaciones', 'Organico');

-- MOVIMIENTO 1: Campanas (10 registros)
INSERT INTO campanas (nombre, objetivo, etapa_recorrido, fecha_inicio, fecha_fin, presupuesto_total) VALUES
  ('Computadoras sin fallas', 'Conseguir contactos interesados en soporte tecnico: computadoras sin fallas.', 'Conciencia', '2026-01-03', '2026-01-28', 88000),
  ('Oficinas conectadas', 'Conseguir contactos interesados en soporte tecnico: oficinas conectadas.', 'Consideracion', '2026-02-03', '2026-02-28', 96000),
  ('Programas al dia', 'Conseguir contactos interesados en soporte tecnico: programas al dia.', 'Decision', '2026-03-03', '2026-03-28', 104000),
  ('Soporte para pymes', 'Conseguir contactos interesados en soporte tecnico: soporte para pymes.', 'Conciencia', '2026-04-03', '2026-04-28', 112000),
  ('Seguridad y respaldo', 'Conseguir contactos interesados en soporte tecnico: seguridad y respaldo.', 'Consideracion', '2026-05-03', '2026-05-28', 120000),
  ('Tecnologia sin interrupciones', 'Conseguir contactos interesados en soporte tecnico: tecnologia sin interrupciones.', 'Decision', '2026-06-03', '2026-06-28', 128000),
  ('Repara y continua', 'Conseguir contactos interesados en soporte tecnico: repara y continua.', 'Conciencia', '2026-07-03', '2026-07-28', 136000),
  ('Redes empresariales', 'Conseguir contactos interesados en soporte tecnico: redes empresariales.', 'Consideracion', '2026-08-03', '2026-08-28', 144000),
  ('Ayuda remota', 'Conseguir contactos interesados en soporte tecnico: ayuda remota.', 'Decision', '2026-09-03', '2026-09-28', 152000),
  ('Cierre de anio tecnologico', 'Conseguir contactos interesados en soporte tecnico: cierre de anio tecnologico.', 'Decision', '2026-10-03', '2026-10-28', 160000);

-- MOVIMIENTO 2: Asignacion de pauta por campana y canal (20 registros)
INSERT INTO asignaciones_presupuesto (id_campana, id_canal, monto_asignado, criterio) VALUES
  (1, 4, 55000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (1, 5, 33000, 'Alcance y recordacion para pequenas empresas.'),
  (2, 4, 60000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (2, 5, 36000, 'Alcance y recordacion para pequenas empresas.'),
  (3, 4, 65000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (3, 5, 39000, 'Alcance y recordacion para pequenas empresas.'),
  (4, 4, 70000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (4, 5, 42000, 'Alcance y recordacion para pequenas empresas.'),
  (5, 4, 75000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (5, 5, 45000, 'Alcance y recordacion para pequenas empresas.'),
  (6, 4, 80000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (6, 5, 48000, 'Alcance y recordacion para pequenas empresas.'),
  (7, 4, 85000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (7, 5, 51000, 'Alcance y recordacion para pequenas empresas.'),
  (8, 4, 90000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (8, 5, 54000, 'Alcance y recordacion para pequenas empresas.'),
  (9, 4, 95000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (9, 5, 57000, 'Alcance y recordacion para pequenas empresas.'),
  (10, 4, 100000, 'Busqueda con intencion de contratar soporte tecnico.'),
  (10, 5, 60000, 'Alcance y recordacion para pequenas empresas.');

-- MOVIMIENTO 3: Contenidos (32 registros)
INSERT INTO contenidos (id_campana, id_canal, id_autor, titulo, tipo_contenido, etapa_recorrido, fecha_programada, fecha_publicacion, estado) VALUES
  (1, 1, 1, 'Consejo practico de tecnologia - campana 1', 'Publicacion', 'Conciencia', '2026-01-07', '2026-01-07', 'Publicado'),
  (1, 4, 2, 'Soluciones de soporte para tu empresa - campana 1', 'Anuncio', 'Conciencia', '2026-01-09', '2026-01-09', 'Publicado'),
  (1, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 1', 'Anuncio', 'Conciencia', '2026-01-11', '2026-01-11', 'Publicado'),
  (2, 1, 1, 'Consejo practico de tecnologia - campana 2', 'Publicacion', 'Consideracion', '2026-02-07', '2026-02-07', 'Publicado'),
  (2, 4, 2, 'Soluciones de soporte para tu empresa - campana 2', 'Anuncio', 'Consideracion', '2026-02-09', '2026-02-09', 'Publicado'),
  (2, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 2', 'Anuncio', 'Consideracion', '2026-02-11', '2026-02-11', 'Publicado'),
  (3, 1, 1, 'Consejo practico de tecnologia - campana 3', 'Publicacion', 'Decision', '2026-03-07', '2026-03-07', 'Publicado'),
  (3, 4, 2, 'Soluciones de soporte para tu empresa - campana 3', 'Anuncio', 'Decision', '2026-03-09', '2026-03-09', 'Publicado'),
  (3, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 3', 'Anuncio', 'Decision', '2026-03-11', '2026-03-11', 'Publicado'),
  (4, 1, 1, 'Consejo practico de tecnologia - campana 4', 'Publicacion', 'Conciencia', '2026-04-07', '2026-04-07', 'Publicado'),
  (4, 4, 2, 'Soluciones de soporte para tu empresa - campana 4', 'Anuncio', 'Conciencia', '2026-04-09', '2026-04-09', 'Publicado'),
  (4, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 4', 'Anuncio', 'Conciencia', '2026-04-11', '2026-04-11', 'Publicado'),
  (5, 1, 1, 'Consejo practico de tecnologia - campana 5', 'Publicacion', 'Consideracion', '2026-05-07', '2026-05-07', 'Publicado'),
  (5, 4, 2, 'Soluciones de soporte para tu empresa - campana 5', 'Anuncio', 'Consideracion', '2026-05-09', '2026-05-09', 'Publicado'),
  (5, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 5', 'Anuncio', 'Consideracion', '2026-05-11', '2026-05-11', 'Publicado'),
  (6, 1, 1, 'Consejo practico de tecnologia - campana 6', 'Publicacion', 'Decision', '2026-06-07', '2026-06-07', 'Publicado'),
  (6, 4, 2, 'Soluciones de soporte para tu empresa - campana 6', 'Anuncio', 'Decision', '2026-06-09', '2026-06-09', 'Publicado'),
  (6, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 6', 'Anuncio', 'Decision', '2026-06-11', '2026-06-11', 'Publicado'),
  (7, 1, 1, 'Consejo practico de tecnologia - campana 7', 'Publicacion', 'Conciencia', '2026-07-07', '2026-07-07', 'Publicado'),
  (7, 4, 2, 'Soluciones de soporte para tu empresa - campana 7', 'Anuncio', 'Conciencia', '2026-07-09', '2026-07-09', 'Publicado'),
  (7, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 7', 'Anuncio', 'Conciencia', '2026-07-11', '2026-07-11', 'Publicado'),
  (8, 1, 1, 'Consejo practico de tecnologia - campana 8', 'Publicacion', 'Consideracion', '2026-08-07', '2026-08-07', 'Publicado'),
  (8, 4, 2, 'Soluciones de soporte para tu empresa - campana 8', 'Anuncio', 'Consideracion', '2026-08-09', '2026-08-09', 'Publicado'),
  (8, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 8', 'Anuncio', 'Consideracion', '2026-08-11', '2026-08-11', 'Publicado'),
  (9, 1, 1, 'Consejo practico de tecnologia - campana 9', 'Publicacion', 'Decision', '2026-09-07', '2026-09-07', 'Publicado'),
  (9, 4, 2, 'Soluciones de soporte para tu empresa - campana 9', 'Anuncio', 'Decision', '2026-09-09', '2026-09-09', 'Publicado'),
  (9, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 9', 'Anuncio', 'Decision', '2026-09-11', '2026-09-11', 'Publicado'),
  (10, 1, 1, 'Consejo practico de tecnologia - campana 10', 'Publicacion', 'Decision', '2026-10-07', '2026-10-07', 'Publicado'),
  (10, 4, 2, 'Soluciones de soporte para tu empresa - campana 10', 'Anuncio', 'Decision', '2026-10-09', '2026-10-09', 'Publicado'),
  (10, 5, 1, 'Conoce los servicios de TecnoAyuda - campana 10', 'Anuncio', 'Decision', '2026-10-11', '2026-10-11', 'Publicado'),
  (9, 5, 1, 'Nueva version de anuncio de seguridad', 'Anuncio', 'Decision', '2026-09-25', NULL, 'Aprobado'),
  (10, 1, 2, 'Publicacion con informacion incompleta', 'Publicacion', 'Conciencia', '2026-10-26', NULL, 'Rechazado');

-- MOVIMIENTO 4: Revisiones y aprobaciones (33 registros)
INSERT INTO revisiones_contenido (id_contenido, id_revisor, fecha_revision, decision, comentario) VALUES
  (1, 3, '2026-01-05 09:00:00', 'Rechazado', 'Revisar ortografia y la oferta.'),
  (1, 3, '2026-01-06 15:00:00', 'Aprobado', 'Texto corregido y aprobado.'),
  (2, 3, '2026-01-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (3, 3, '2026-01-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (4, 3, '2026-02-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (5, 3, '2026-02-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (6, 3, '2026-02-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (7, 3, '2026-03-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (8, 3, '2026-03-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (9, 3, '2026-03-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (10, 3, '2026-04-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (11, 3, '2026-04-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (12, 3, '2026-04-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (13, 3, '2026-05-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (14, 3, '2026-05-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (15, 3, '2026-05-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (16, 3, '2026-06-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (17, 3, '2026-06-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (18, 3, '2026-06-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (19, 3, '2026-07-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (20, 3, '2026-07-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (21, 3, '2026-07-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (22, 3, '2026-08-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (23, 3, '2026-08-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (24, 3, '2026-08-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (25, 3, '2026-09-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (26, 3, '2026-09-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (27, 3, '2026-09-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (28, 3, '2026-10-06 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (29, 3, '2026-10-08 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (30, 3, '2026-10-10 10:00:00', 'Aprobado', 'Revisado por gerencia; contenido listo.'),
  (31, 3, '2026-09-24 10:00:00', 'Aprobado', 'Programada, a la espera de publicacion.'),
  (32, 3, '2026-10-25 10:00:00', 'Rechazado', 'Informacion de la oferta incompleta.');

-- MOVIMIENTO 5: Contactos y leads (20 registros)
INSERT INTO contactos (nombre, empresa, correo, telefono, fecha_registro, etapa_recorrido, id_campana_origen, id_canal_origen) VALUES
  ('Andrea Jimenez', 'Empresa ejemplo 01', 'contacto01@correo.ejemplo', '8888-1001', '2026-01-12 09:00:00', 'Conciencia', 1, 4),
  ('Pablo Flores', 'Empresa ejemplo 02', 'contacto02@correo.ejemplo', '8888-1002', '2026-01-14 09:00:00', 'Conciencia', 1, 5),
  ('Laura Quiros', 'Empresa ejemplo 03', 'contacto03@correo.ejemplo', '8888-1003', '2026-02-12 09:00:00', 'Consideracion', 2, 4),
  ('Jose Segura', 'Empresa ejemplo 04', 'contacto04@correo.ejemplo', '8888-1004', '2026-02-14 09:00:00', 'Consideracion', 2, 5),
  ('Natalia Molina', 'Empresa ejemplo 05', 'contacto05@correo.ejemplo', '8888-1005', '2026-03-12 09:00:00', 'Decision', 3, 4),
  ('Brandon Vega', 'Empresa ejemplo 06', 'contacto06@correo.ejemplo', '8888-1006', '2026-03-14 09:00:00', 'Decision', 3, 5),
  ('Karla Hernandez', 'Empresa ejemplo 07', 'contacto07@correo.ejemplo', '8888-1007', '2026-04-12 09:00:00', 'Conciencia', 4, 4),
  ('Mario Araya', 'Empresa ejemplo 08', 'contacto08@correo.ejemplo', '8888-1008', '2026-04-14 09:00:00', 'Conciencia', 4, 5),
  ('Lucia Navarro', 'Empresa ejemplo 09', 'contacto09@correo.ejemplo', '8888-1009', '2026-05-12 09:00:00', 'Consideracion', 5, 4),
  ('Daniel Porras', 'Empresa ejemplo 10', 'contacto10@correo.ejemplo', '8888-1010', '2026-05-14 09:00:00', 'Consideracion', 5, 5),
  ('Paola Mena', 'Empresa ejemplo 11', 'contacto11@correo.ejemplo', '8888-1011', '2026-06-12 09:00:00', 'Decision', 6, 4),
  ('Andres Castro', 'Empresa ejemplo 12', 'contacto12@correo.ejemplo', '8888-1012', '2026-06-14 09:00:00', 'Decision', 6, 5),
  ('Melissa Soto', 'Empresa ejemplo 13', 'contacto13@correo.ejemplo', '8888-1013', '2026-07-12 09:00:00', 'Conciencia', 7, 4),
  ('Rafael Herrera', 'Empresa ejemplo 14', 'contacto14@correo.ejemplo', '8888-1014', '2026-07-14 09:00:00', 'Conciencia', 7, 5),
  ('Ana Rodriguez', 'Empresa ejemplo 15', 'contacto15@correo.ejemplo', '8888-1015', '2026-08-12 09:00:00', 'Consideracion', 8, 4),
  ('Kevin Morales', 'Empresa ejemplo 16', 'contacto16@correo.ejemplo', '8888-1016', '2026-08-14 09:00:00', 'Consideracion', 8, 5),
  ('Valeria Acosta', 'Empresa ejemplo 17', 'contacto17@correo.ejemplo', '8888-1017', '2026-09-12 09:00:00', 'Decision', 9, 4),
  ('Jorge Cordero', 'Empresa ejemplo 18', 'contacto18@correo.ejemplo', '8888-1018', '2026-09-14 09:00:00', 'Decision', 9, 5),
  ('Elena Salas', 'Empresa ejemplo 19', 'contacto19@correo.ejemplo', '8888-1019', '2026-10-12 09:00:00', 'Decision', 10, 4),
  ('Felipe Rojas', 'Empresa ejemplo 20', 'contacto20@correo.ejemplo', '8888-1020', '2026-10-14 09:00:00', 'Decision', 10, 5);

-- MOVIMIENTO 6: Historial cronologico del embudo (64 registros)
INSERT INTO historial_embudo (id_contacto, etapa_embudo, fecha_movimiento) VALUES
  (1, 'Lead', '2026-01-12 09:00:00'),
  (1, 'Prospecto', '2026-01-16 10:00:00'),
  (1, 'Oportunidad', '2026-01-20 11:00:00'),
  (1, 'Cierre', '2026-01-25 16:00:00'),
  (2, 'Lead', '2026-01-14 09:00:00'),
  (2, 'Prospecto', '2026-01-16 10:00:00'),
  (2, 'Oportunidad', '2026-01-20 11:00:00'),
  (3, 'Lead', '2026-02-12 09:00:00'),
  (3, 'Prospecto', '2026-02-16 10:00:00'),
  (3, 'Oportunidad', '2026-02-20 11:00:00'),
  (3, 'Cierre', '2026-02-25 16:00:00'),
  (4, 'Lead', '2026-02-14 09:00:00'),
  (4, 'Prospecto', '2026-02-16 10:00:00'),
  (4, 'Oportunidad', '2026-02-20 11:00:00'),
  (5, 'Lead', '2026-03-12 09:00:00'),
  (5, 'Prospecto', '2026-03-16 10:00:00'),
  (5, 'Oportunidad', '2026-03-20 11:00:00'),
  (5, 'Cierre', '2026-03-25 16:00:00'),
  (6, 'Lead', '2026-03-14 09:00:00'),
  (6, 'Prospecto', '2026-03-16 10:00:00'),
  (6, 'Oportunidad', '2026-03-20 11:00:00'),
  (7, 'Lead', '2026-04-12 09:00:00'),
  (7, 'Prospecto', '2026-04-16 10:00:00'),
  (7, 'Oportunidad', '2026-04-20 11:00:00'),
  (7, 'Cierre', '2026-04-25 16:00:00'),
  (8, 'Lead', '2026-04-14 09:00:00'),
  (8, 'Prospecto', '2026-04-16 10:00:00'),
  (8, 'Oportunidad', '2026-04-20 11:00:00'),
  (9, 'Lead', '2026-05-12 09:00:00'),
  (9, 'Prospecto', '2026-05-16 10:00:00'),
  (9, 'Oportunidad', '2026-05-20 11:00:00'),
  (9, 'Cierre', '2026-05-25 16:00:00'),
  (10, 'Lead', '2026-05-14 09:00:00'),
  (10, 'Prospecto', '2026-05-16 10:00:00'),
  (10, 'Oportunidad', '2026-05-20 11:00:00'),
  (11, 'Lead', '2026-06-12 09:00:00'),
  (11, 'Prospecto', '2026-06-16 10:00:00'),
  (11, 'Oportunidad', '2026-06-20 11:00:00'),
  (11, 'Cierre', '2026-06-25 16:00:00'),
  (12, 'Lead', '2026-06-14 09:00:00'),
  (12, 'Prospecto', '2026-06-16 10:00:00'),
  (12, 'Oportunidad', '2026-06-20 11:00:00'),
  (13, 'Lead', '2026-07-12 09:00:00'),
  (13, 'Prospecto', '2026-07-16 10:00:00'),
  (13, 'Oportunidad', '2026-07-20 11:00:00'),
  (13, 'Cierre', '2026-07-25 16:00:00'),
  (14, 'Lead', '2026-07-14 09:00:00'),
  (14, 'Prospecto', '2026-07-16 10:00:00'),
  (15, 'Lead', '2026-08-12 09:00:00'),
  (15, 'Prospecto', '2026-08-16 10:00:00'),
  (15, 'Oportunidad', '2026-08-20 11:00:00'),
  (15, 'Cierre', '2026-08-25 16:00:00'),
  (16, 'Lead', '2026-08-14 09:00:00'),
  (16, 'Prospecto', '2026-08-16 10:00:00'),
  (17, 'Lead', '2026-09-12 09:00:00'),
  (17, 'Prospecto', '2026-09-16 10:00:00'),
  (17, 'Oportunidad', '2026-09-20 11:00:00'),
  (17, 'Cierre', '2026-09-25 16:00:00'),
  (18, 'Lead', '2026-09-14 09:00:00'),
  (19, 'Lead', '2026-10-12 09:00:00'),
  (19, 'Prospecto', '2026-10-16 10:00:00'),
  (19, 'Oportunidad', '2026-10-20 11:00:00'),
  (19, 'Cierre', '2026-10-25 16:00:00'),
  (20, 'Lead', '2026-10-14 09:00:00');

-- MOVIMIENTO 7: Interacciones de contactos con contenidos (30 registros)
INSERT INTO interacciones_contenido (id_contacto, id_contenido, tipo_interaccion, fecha_interaccion) VALUES
  (1, 2, 'Clic en anuncio', '2026-01-12 10:00:00'),
  (2, 3, 'Clic en anuncio', '2026-01-14 10:00:00'),
  (1, 1, 'Lectura identificada', '2026-01-13 09:00:00'),
  (3, 5, 'Clic en anuncio', '2026-02-12 10:00:00'),
  (4, 6, 'Clic en anuncio', '2026-02-14 10:00:00'),
  (3, 4, 'Lectura identificada', '2026-02-13 09:00:00'),
  (5, 8, 'Clic en anuncio', '2026-03-12 10:00:00'),
  (6, 9, 'Clic en anuncio', '2026-03-14 10:00:00'),
  (5, 7, 'Lectura identificada', '2026-03-13 09:00:00'),
  (7, 11, 'Clic en anuncio', '2026-04-12 10:00:00'),
  (8, 12, 'Clic en anuncio', '2026-04-14 10:00:00'),
  (7, 10, 'Lectura identificada', '2026-04-13 09:00:00'),
  (9, 14, 'Clic en anuncio', '2026-05-12 10:00:00'),
  (10, 15, 'Clic en anuncio', '2026-05-14 10:00:00'),
  (9, 13, 'Lectura identificada', '2026-05-13 09:00:00'),
  (11, 17, 'Clic en anuncio', '2026-06-12 10:00:00'),
  (12, 18, 'Clic en anuncio', '2026-06-14 10:00:00'),
  (11, 16, 'Lectura identificada', '2026-06-13 09:00:00'),
  (13, 20, 'Clic en anuncio', '2026-07-12 10:00:00'),
  (14, 21, 'Clic en anuncio', '2026-07-14 10:00:00'),
  (13, 19, 'Lectura identificada', '2026-07-13 09:00:00'),
  (15, 23, 'Clic en anuncio', '2026-08-12 10:00:00'),
  (16, 24, 'Clic en anuncio', '2026-08-14 10:00:00'),
  (15, 22, 'Lectura identificada', '2026-08-13 09:00:00'),
  (17, 26, 'Clic en anuncio', '2026-09-12 10:00:00'),
  (18, 27, 'Clic en anuncio', '2026-09-14 10:00:00'),
  (17, 25, 'Lectura identificada', '2026-09-13 09:00:00'),
  (19, 29, 'Clic en anuncio', '2026-10-12 10:00:00'),
  (20, 30, 'Clic en anuncio', '2026-10-14 10:00:00'),
  (19, 28, 'Lectura identificada', '2026-10-13 09:00:00');

-- MOVIMIENTO 8: Traspasos de mercadeo a ventas (18 registros)
INSERT INTO traspasos_ventas (id_contacto, id_entrega, id_recibe, fecha_traspaso, puntuacion, necesidad, presupuesto_declarado, resumen_contenidos, notas, estado, fecha_respuesta, motivo_rechazo) VALUES
  (1, 1, 4, '2026-01-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-01-17 12:00:00', NULL),
  (2, 1, 4, '2026-01-17 09:00:00', 60, 'Necesita soporte tecnico de oficina.', 150000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-01-17 12:00:00', NULL),
  (3, 1, 5, '2026-02-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-02-17 12:00:00', NULL),
  (4, 1, 5, '2026-02-17 09:00:00', 60, 'Necesita soporte tecnico de oficina.', 150000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-02-17 12:00:00', NULL),
  (5, 1, 4, '2026-03-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-03-17 12:00:00', NULL),
  (6, 1, 4, '2026-03-17 09:00:00', 60, 'Necesita soporte tecnico de oficina.', 150000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-03-17 12:00:00', NULL),
  (7, 1, 5, '2026-04-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-04-17 12:00:00', NULL),
  (8, 1, 5, '2026-04-17 09:00:00', 60, 'Necesita soporte tecnico de oficina.', 150000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-04-17 12:00:00', NULL),
  (9, 1, 4, '2026-05-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-05-17 12:00:00', NULL),
  (10, 1, 4, '2026-05-17 09:00:00', 60, 'Necesita soporte tecnico de oficina.', 150000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-05-17 12:00:00', NULL),
  (11, 1, 5, '2026-06-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-06-17 12:00:00', NULL),
  (12, 1, 5, '2026-06-17 09:00:00', 60, 'Necesita soporte tecnico de oficina.', 150000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-06-17 12:00:00', NULL),
  (13, 1, 4, '2026-07-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-07-17 12:00:00', NULL),
  (14, 1, 5, '2026-07-17 09:00:00', 35, 'Consulta general sin presupuesto definido.', NULL, 'Vio el anuncio inicial.', 'Falta informacion para cotizar.', 'Rechazado', '2026-07-17 12:00:00', 'No tiene presupuesto confirmado.'),
  (15, 1, 5, '2026-08-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-08-17 12:00:00', NULL),
  (16, 1, 5, '2026-08-17 09:00:00', 35, 'Consulta general sin presupuesto definido.', NULL, 'Vio el anuncio inicial.', 'Falta informacion para cotizar.', 'Rechazado', '2026-08-17 12:00:00', 'No tiene presupuesto confirmado.'),
  (17, 1, 4, '2026-09-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-09-17 12:00:00', NULL),
  (19, 1, 5, '2026-10-17 09:00:00', 80, 'Necesita soporte tecnico de oficina.', 250000, 'Vio anuncios y solicito informacion.', 'Datos verificados.', 'Aceptado', '2026-10-17 12:00:00', NULL);

-- MOVIMIENTO 9: Oportunidades (16 registros)
INSERT INTO oportunidades_venta (id_contacto, id_servicio, id_vendedor, fecha_propuesta, monto_estimado, estado) VALUES
  (1, 1, 4, '2026-01-20', 120000, 'Ganada'),
  (2, 4, 4, '2026-01-20', 250000, 'Perdida'),
  (3, 2, 5, '2026-02-20', 180000, 'Ganada'),
  (4, 5, 5, '2026-02-20', 160000, 'Perdida'),
  (5, 3, 4, '2026-03-20', 95000, 'Ganada'),
  (6, 6, 4, '2026-03-20', 300000, 'Perdida'),
  (7, 4, 5, '2026-04-20', 250000, 'Ganada'),
  (8, 1, 5, '2026-04-20', 120000, 'Perdida'),
  (9, 5, 4, '2026-05-20', 160000, 'Ganada'),
  (10, 2, 4, '2026-05-20', 180000, 'Abierta'),
  (11, 6, 5, '2026-06-20', 300000, 'Ganada'),
  (12, 3, 5, '2026-06-20', 95000, 'Abierta'),
  (13, 1, 4, '2026-07-20', 120000, 'Ganada'),
  (15, 2, 5, '2026-08-20', 180000, 'Ganada'),
  (17, 3, 4, '2026-09-20', 95000, 'Ganada'),
  (19, 4, 5, '2026-10-20', 250000, 'Ganada');

-- MOVIMIENTO 10: Contratos firmados (10 registros)
INSERT INTO contratos (id_oportunidad, fecha_firma, monto_final) VALUES
  (1, '2026-01-25', 120000),
  (3, '2026-02-25', 180000),
  (5, '2026-03-25', 95000),
  (7, '2026-04-25', 250000),
  (9, '2026-05-25', 160000),
  (11, '2026-06-25', 300000),
  (13, '2026-07-25', 120000),
  (14, '2026-08-25', 180000),
  (15, '2026-09-25', 95000),
  (16, '2026-10-25', 250000);

-- MOVIMIENTO 11: Gastos de pauta, mercadeo y ventas (40 registros)
INSERT INTO gastos (id_campana, id_canal, categoria_gasto, monto, fecha_gasto) VALUES
  (1, 4, 'Pauta', 44000, '2026-01-20'),
  (1, 5, 'Pauta', 26400, '2026-01-20'),
  (1, NULL, 'Mercadeo', 12000, '2026-01-21'),
  (1, NULL, 'Ventas', 10000, '2026-01-22'),
  (2, 4, 'Pauta', 48000, '2026-02-20'),
  (2, 5, 'Pauta', 28800, '2026-02-20'),
  (2, NULL, 'Mercadeo', 12000, '2026-02-21'),
  (2, NULL, 'Ventas', 10000, '2026-02-22'),
  (3, 4, 'Pauta', 52000, '2026-03-20'),
  (3, 5, 'Pauta', 31200, '2026-03-20'),
  (3, NULL, 'Mercadeo', 12000, '2026-03-21'),
  (3, NULL, 'Ventas', 10000, '2026-03-22'),
  (4, 4, 'Pauta', 56000, '2026-04-20'),
  (4, 5, 'Pauta', 33600, '2026-04-20'),
  (4, NULL, 'Mercadeo', 12000, '2026-04-21'),
  (4, NULL, 'Ventas', 10000, '2026-04-22'),
  (5, 4, 'Pauta', 60000, '2026-05-20'),
  (5, 5, 'Pauta', 36000, '2026-05-20'),
  (5, NULL, 'Mercadeo', 12000, '2026-05-21'),
  (5, NULL, 'Ventas', 10000, '2026-05-22'),
  (6, 4, 'Pauta', 64000, '2026-06-20'),
  (6, 5, 'Pauta', 38400, '2026-06-20'),
  (6, NULL, 'Mercadeo', 12000, '2026-06-21'),
  (6, NULL, 'Ventas', 10000, '2026-06-22'),
  (7, 4, 'Pauta', 68000, '2026-07-20'),
  (7, 5, 'Pauta', 40800, '2026-07-20'),
  (7, NULL, 'Mercadeo', 12000, '2026-07-21'),
  (7, NULL, 'Ventas', 10000, '2026-07-22'),
  (8, 4, 'Pauta', 72000, '2026-08-20'),
  (8, 5, 'Pauta', 43200, '2026-08-20'),
  (8, NULL, 'Mercadeo', 12000, '2026-08-21'),
  (8, NULL, 'Ventas', 10000, '2026-08-22'),
  (9, 4, 'Pauta', 76000, '2026-09-20'),
  (9, 5, 'Pauta', 45600, '2026-09-20'),
  (9, NULL, 'Mercadeo', 12000, '2026-09-21'),
  (9, NULL, 'Ventas', 10000, '2026-09-22'),
  (10, 4, 'Pauta', 80000, '2026-10-20'),
  (10, 5, 'Pauta', 48000, '2026-10-20'),
  (10, NULL, 'Mercadeo', 12000, '2026-10-21'),
  (10, NULL, 'Ventas', 10000, '2026-10-22');

-- MOVIMIENTO 12: Resultados medibles de los canales (30 registros)
INSERT INTO resultados_campana (id_campana, id_canal, fecha, impresiones, clics, me_gusta, visualizaciones, seguidores_nuevos) VALUES
  (1, 1, '2026-01-22', 3170, 99, 125, 1053, 13),
  (1, 4, '2026-01-22', 4400, 188, 0, 0, 0),
  (1, 5, '2026-01-22', 5680, 209, 59, 990, 11),
  (2, 1, '2026-02-22', 3340, 103, 130, 1106, 14),
  (2, 4, '2026-02-22', 4600, 196, 0, 0, 0),
  (2, 5, '2026-02-22', 5860, 218, 63, 1030, 12),
  (3, 1, '2026-03-22', 3510, 107, 135, 1159, 15),
  (3, 4, '2026-03-22', 4800, 204, 0, 0, 0),
  (3, 5, '2026-03-22', 6040, 227, 67, 1070, 13),
  (4, 1, '2026-04-22', 3680, 111, 140, 1212, 16),
  (4, 4, '2026-04-22', 5000, 212, 0, 0, 0),
  (4, 5, '2026-04-22', 6220, 236, 71, 1110, 14),
  (5, 1, '2026-05-22', 3850, 115, 145, 1265, 17),
  (5, 4, '2026-05-22', 5200, 220, 0, 0, 0),
  (5, 5, '2026-05-22', 6400, 245, 75, 1150, 15),
  (6, 1, '2026-06-22', 4020, 119, 150, 1318, 18),
  (6, 4, '2026-06-22', 5400, 228, 0, 0, 0),
  (6, 5, '2026-06-22', 6580, 254, 79, 1190, 16),
  (7, 1, '2026-07-22', 4190, 123, 155, 1371, 19),
  (7, 4, '2026-07-22', 5600, 236, 0, 0, 0),
  (7, 5, '2026-07-22', 6760, 263, 83, 1230, 17),
  (8, 1, '2026-08-22', 4360, 127, 160, 1424, 20),
  (8, 4, '2026-08-22', 5800, 244, 0, 0, 0),
  (8, 5, '2026-08-22', 6940, 272, 87, 1270, 18),
  (9, 1, '2026-09-22', 4530, 131, 165, 1477, 21),
  (9, 4, '2026-09-22', 6000, 252, 0, 0, 0),
  (9, 5, '2026-09-22', 7120, 281, 91, 1310, 19),
  (10, 1, '2026-10-22', 4700, 135, 170, 1530, 22),
  (10, 4, '2026-10-22', 6200, 260, 0, 0, 0),
  (10, 5, '2026-10-22', 7300, 290, 95, 1350, 20);

-- ================================================================
-- PARTE 3. CONSULTAS PARA EVALUACION (DQL)
-- Ejecutar el archivo COMPLETO para ver todos los resultados.
-- NOTA: se muestran numeros en colones costarricenses (CRC).
-- Los anuncios y resultados son ejemplos inventados.
-- ================================================================

-- CONTROL 1: Ver las 15 tablas.
SHOW TABLES;

-- CONTROL 2: Total de tablas, debe ser 15.
SELECT COUNT(*) AS total_tablas
FROM information_schema.tables
WHERE table_schema = 'tecnoayuda_entrega'
  AND table_type = 'BASE TABLE';

-- CONTROL 3: Cantidad de registros por cada tabla.
SELECT 'empleados' AS tabla, COUNT(*) AS registros FROM empleados
UNION ALL SELECT 'servicios', COUNT(*) FROM servicios
UNION ALL SELECT 'canales', COUNT(*) FROM canales
UNION ALL SELECT 'campanas', COUNT(*) FROM campanas
UNION ALL SELECT 'asignaciones_presupuesto', COUNT(*) FROM asignaciones_presupuesto
UNION ALL SELECT 'contenidos', COUNT(*) FROM contenidos
UNION ALL SELECT 'revisiones_contenido', COUNT(*) FROM revisiones_contenido
UNION ALL SELECT 'contactos', COUNT(*) FROM contactos
UNION ALL SELECT 'historial_embudo', COUNT(*) FROM historial_embudo
UNION ALL SELECT 'interacciones_contenido', COUNT(*) FROM interacciones_contenido
UNION ALL SELECT 'traspasos_ventas', COUNT(*) FROM traspasos_ventas
UNION ALL SELECT 'oportunidades_venta', COUNT(*) FROM oportunidades_venta
UNION ALL SELECT 'contratos', COUNT(*) FROM contratos
UNION ALL SELECT 'gastos', COUNT(*) FROM gastos
UNION ALL SELECT 'resultados_campana', COUNT(*) FROM resultados_campana;

-- CONSULTA 1: CPC = gasto de pauta / cantidad de clics.
-- Primero agrupar gastos y clics por separado para NO multiplicar filas.
WITH pauta AS (
  SELECT id_canal, SUM(monto) AS monto_pauta
  FROM gastos WHERE categoria_gasto = 'Pauta' GROUP BY id_canal
), clics AS (
  SELECT id_canal, SUM(clics) AS clics_totales
  FROM resultados_campana GROUP BY id_canal
)
SELECT ca.nombre AS canal, p.monto_pauta AS gasto_crc,
       cl.clics_totales AS clics,
       ROUND(p.monto_pauta / NULLIF(cl.clics_totales,0),2) AS cpc_crc
FROM pauta p
JOIN clics cl ON cl.id_canal = p.id_canal
JOIN canales ca ON ca.id_canal = p.id_canal
ORDER BY ca.nombre;

-- CONSULTA 2: CTR = clics / impresiones * 100.
SELECT ca.nombre AS canal, ca.tipo,
       SUM(r.impresiones) AS impresiones,
       SUM(r.clics) AS clics,
       ROUND(100.0 * SUM(r.clics) / NULLIF(SUM(r.impresiones),0),2) AS ctr_porcentaje
FROM resultados_campana r
JOIN canales ca ON ca.id_canal = r.id_canal
GROUP BY ca.id_canal, ca.nombre, ca.tipo
ORDER BY ca.nombre;

-- CONSULTA 3: CAC = gasto de pauta + mercadeo + ventas / clientes nuevos.
-- Un cliente nuevo es un contacto DISTINTO con contrato firmado.
SELECT ROUND(
    (SELECT SUM(monto) FROM gastos WHERE categoria_gasto IN ('Pauta','Mercadeo','Ventas'))
    / NULLIF(COUNT(DISTINCT o.id_contacto),0), 2
  ) AS cac_crc,
  COUNT(DISTINCT o.id_contacto) AS clientes_nuevos,
  (SELECT SUM(monto) FROM gastos WHERE categoria_gasto IN ('Pauta','Mercadeo','Ventas')) AS inversion_total_crc
FROM contratos co
JOIN oportunidades_venta o ON o.id_oportunidad = co.id_oportunidad;

-- CONSULTA 4: ROAS = ingresos asociados a la campana / costo de pauta.
-- Regla de atribucion elegida: cada contrato cuenta para la campana
-- de ORIGEN del contacto (no se atribuye a todas las campanas que vio).
WITH inversion AS (
  SELECT id_campana, SUM(monto) AS gasto_pauta
  FROM gastos WHERE categoria_gasto = 'Pauta' GROUP BY id_campana
), ingresos AS (
  SELECT ct.id_campana_origen AS id_campana,
         SUM(co.monto_final) AS ingresos_atribuidos
  FROM contratos co
  JOIN oportunidades_venta o ON o.id_oportunidad = co.id_oportunidad
  JOIN contactos ct ON ct.id_contacto = o.id_contacto
  GROUP BY ct.id_campana_origen
)
SELECT ca.nombre AS campana,
       COALESCE(i.gasto_pauta,0) AS pauta_crc,
       COALESCE(ing.ingresos_atribuidos,0) AS ingresos_crc,
       ROUND(COALESCE(ing.ingresos_atribuidos,0) / NULLIF(i.gasto_pauta,0),2) AS roas
FROM campanas ca
LEFT JOIN inversion i ON i.id_campana = ca.id_campana
LEFT JOIN ingresos ing ON ing.id_campana = ca.id_campana
ORDER BY ca.id_campana;

-- CONSULTA 5: Conversion entre Lead, Prospecto, Oportunidad, Cierre.
-- Se cuentan CONTACTOS UNICOS por etapa, no movimientos repetidos.
WITH etapas AS (
  SELECT
    COUNT(DISTINCT CASE WHEN etapa_embudo = 'Lead' THEN id_contacto END) AS leads,
    COUNT(DISTINCT CASE WHEN etapa_embudo = 'Prospecto' THEN id_contacto END) AS prospectos,
    COUNT(DISTINCT CASE WHEN etapa_embudo = 'Oportunidad' THEN id_contacto END) AS oportunidades,
    COUNT(DISTINCT CASE WHEN etapa_embudo = 'Cierre' THEN id_contacto END) AS cierres
  FROM historial_embudo
)
SELECT 'Lead a Prospecto' AS conversion, leads AS inicio, prospectos AS final,
       ROUND(100.0 * prospectos / NULLIF(leads,0),2) AS porcentaje
FROM etapas
UNION ALL
SELECT 'Prospecto a Oportunidad', prospectos, oportunidades,
       ROUND(100.0 * oportunidades / NULLIF(prospectos,0),2)
FROM etapas
UNION ALL
SELECT 'Oportunidad a Cierre', oportunidades, cierres,
       ROUND(100.0 * cierres / NULLIF(oportunidades,0),2)
FROM etapas;

-- CONSULTA 6: Ciclo de venta = dias entre registro del lead y contrato.
SELECT COUNT(*) AS contratos_firmados,
       ROUND(AVG(DATEDIFF(co.fecha_firma, DATE(ct.fecha_registro))),2) AS ciclo_promedio_dias,
       MIN(DATEDIFF(co.fecha_firma, DATE(ct.fecha_registro))) AS minimo_dias,
       MAX(DATEDIFF(co.fecha_firma, DATE(ct.fecha_registro))) AS maximo_dias
FROM contratos co
JOIN oportunidades_venta o ON o.id_oportunidad = co.id_oportunidad
JOIN contactos ct ON ct.id_contacto = o.id_contacto;

-- CONSULTA 7: Ticket promedio = suma de contratos / numero de contratos.
SELECT COUNT(*) AS contratos,
       SUM(monto_final) AS ingresos_totales_crc,
       ROUND(AVG(monto_final),2) AS ticket_promedio_crc
FROM contratos;

-- CONSULTA 8: Metricas de vanidad VS negocio por campana.
-- Se agrupa cada fuente primero para no duplicar datos al hacer JOIN.
WITH vanidad AS (
  SELECT id_campana,
         SUM(me_gusta) AS me_gusta,
         SUM(visualizaciones) AS visualizaciones,
         SUM(seguidores_nuevos) AS seguidores_nuevos
  FROM resultados_campana GROUP BY id_campana
), leads AS (
  SELECT id_campana_origen AS id_campana, COUNT(*) AS cantidad_leads
  FROM contactos GROUP BY id_campana_origen
), ventas AS (
  SELECT ct.id_campana_origen AS id_campana,
         COUNT(*) AS contratos,
         SUM(co.monto_final) AS ingresos_crc
  FROM contratos co
  JOIN oportunidades_venta o ON o.id_oportunidad = co.id_oportunidad
  JOIN contactos ct ON ct.id_contacto = o.id_contacto
  GROUP BY ct.id_campana_origen
)
SELECT ca.nombre AS campana,
       COALESCE(v.me_gusta,0) AS me_gusta,
       COALESCE(v.visualizaciones,0) AS visualizaciones,
       COALESCE(v.seguidores_nuevos,0) AS seguidores_nuevos,
       COALESCE(l.cantidad_leads,0) AS leads,
       COALESCE(ve.contratos,0) AS contratos,
       COALESCE(ve.ingresos_crc,0) AS ingresos_crc,
       ROUND(100.0 * COALESCE(ve.contratos,0) / NULLIF(l.cantidad_leads,0),2) AS conversion_lead_a_contrato_pct
FROM campanas ca
LEFT JOIN vanidad v ON v.id_campana = ca.id_campana
LEFT JOIN leads l ON l.id_campana = ca.id_campana
LEFT JOIN ventas ve ON ve.id_campana = ca.id_campana
ORDER BY ca.id_campana;

-- CONSULTA EXTRA: presupuesto asignado vs gasto de pauta real por campana.
WITH asignado AS (
  SELECT id_campana, SUM(monto_asignado) AS asignado_crc
  FROM asignaciones_presupuesto GROUP BY id_campana
), gastado AS (
  SELECT id_campana, SUM(monto) AS gastado_crc
  FROM gastos WHERE categoria_gasto = 'Pauta' GROUP BY id_campana
)
SELECT c.nombre AS campana, c.presupuesto_total AS presupuesto_total_crc,
       COALESCE(a.asignado_crc,0) AS asignado_crc,
       COALESCE(g.gastado_crc,0) AS gastado_crc,
       COALESCE(a.asignado_crc,0) - COALESCE(g.gastado_crc,0) AS pauta_disponible_crc
FROM campanas c
LEFT JOIN asignado a ON a.id_campana = c.id_campana
LEFT JOIN gastado g ON g.id_campana = c.id_campana
ORDER BY c.id_campana;

-- FIN. Capturar en Workbench: las 15 tablas y resultados de consultas.
