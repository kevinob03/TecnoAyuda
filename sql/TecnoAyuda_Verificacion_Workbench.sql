-- ===============================================================
-- TECNOAYUDA: VERIFICACION EN MYSQL WORKBENCH (SOLO LECTURA)
-- Ejecutar DESPUES de TecnoAyuda_Completo.sql.
-- Este archivo NO crea, modifica ni elimina datos.
-- Las capturas de resultados deben tomarse en el Workbench real.
-- ===============================================================
USE tecnoayuda_entrega;

-- EVIDENCIA 1. La base tiene exactamente 15 tablas.
SELECT COUNT(*) AS total_tablas,
       CASE WHEN COUNT(*) = 15 THEN 'OK' ELSE 'REVISAR' END AS estado
FROM information_schema.tables
WHERE table_schema = 'tecnoayuda_entrega' AND table_type = 'BASE TABLE';

-- EVIDENCIA 2. Cantidad de registros (catalogos >=5, movimientos >=10).
SELECT tabla, registros, minimo,
       CASE WHEN registros >= minimo THEN 'OK' ELSE 'REVISAR' END AS estado
FROM (
 SELECT 'empleados' tabla, COUNT(*) registros, 5 minimo FROM empleados
 UNION ALL SELECT 'servicios', COUNT(*), 5 FROM servicios
 UNION ALL SELECT 'canales', COUNT(*), 5 FROM canales
 UNION ALL SELECT 'campanas', COUNT(*), 10 FROM campanas
 UNION ALL SELECT 'asignaciones_presupuesto', COUNT(*), 10 FROM asignaciones_presupuesto
 UNION ALL SELECT 'contenidos', COUNT(*), 10 FROM contenidos
 UNION ALL SELECT 'revisiones_contenido', COUNT(*), 10 FROM revisiones_contenido
 UNION ALL SELECT 'contactos', COUNT(*), 10 FROM contactos
 UNION ALL SELECT 'historial_embudo', COUNT(*), 10 FROM historial_embudo
 UNION ALL SELECT 'interacciones_contenido', COUNT(*), 10 FROM interacciones_contenido
 UNION ALL SELECT 'traspasos_ventas', COUNT(*), 10 FROM traspasos_ventas
 UNION ALL SELECT 'oportunidades_venta', COUNT(*), 10 FROM oportunidades_venta
 UNION ALL SELECT 'contratos', COUNT(*), 10 FROM contratos
 UNION ALL SELECT 'gastos', COUNT(*), 10 FROM gastos
 UNION ALL SELECT 'resultados_campana', COUNT(*), 10 FROM resultados_campana
) AS resumen
ORDER BY tabla;

-- EVIDENCIA 3. Verificar que no haya contratos con oportunidades no ganadas.
SELECT COUNT(*) AS contratos_incoherentes,
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVISAR' END AS estado
FROM contratos co JOIN oportunidades_venta o
ON o.id_oportunidad = co.id_oportunidad
WHERE o.estado <> 'Ganada';

-- EVIDENCIA 4. Resumen de gastos e ingresos de datos ficticios.
SELECT (SELECT COUNT(*) FROM contratos) AS contratos,
       (SELECT SUM(monto_final) FROM contratos) AS ingresos_crc,
       (SELECT SUM(monto) FROM gastos) AS gastos_crc;

-- Las 8 consultas de métricas exigidas ya están al final de
-- TecnoAyuda_Completo.sql. Ejecutarlas allí y capturar resultados.
