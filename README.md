# TecnoAyuda — Business Solutions

Proyecto académico ficticio de mercadeo comercial para una empresa de servicios de soporte técnico.

**Estudiante:** Kevin Ortiz Bolaños  
**Institución:** Forward Costa Rica  
**Programa:** Full Stack  
**Módulo:** Business Solutions  
**Profesor:** Steven Salas Ledezma  
**Fecha del ejercicio:** 29 de octubre de 2026  
**Carné:** No aplica.

## Entregables

| Entregable | Archivo |
|---|---|
| Informe completo de la Parte A y Parte B (PDF, con portada y diagramas) | [Informe PDF](documentacion/TecnoAyuda_Informe_Final.pdf) |
| Informe editable | [Informe Word](documentacion/TecnoAyuda_Informe_Final.docx) |
| Creación de base de datos, 15 tablas, datos ficticios y consultas SQL | [Script principal](sql/TecnoAyuda_Completo.sql) |
| Consultas adicionales de verificación | [Verificación Workbench](sql/TecnoAyuda_Verificacion_Workbench.sql) |
| Diagrama entidad-relación (editable) | [Diagrama ER](diagramas/TecnoAyuda_Diagrama_ER.drawio) |
| Embudo de ventas (editable) | [Embudo](diagramas/TecnoAyuda_Embudo_Ventas.drawio) |
| Diagrama del agente orquestador y agentes especialistas (editable) | [Arquitectura](diagramas/TecnoAyuda_Arquitectura_Agentes.drawio) |
| Captura real de una consulta de presupuestos | [Evidencia 1](evidencias/evidencia_1_mysql.png) |
| Captura real con resultado de 15 tablas | [Evidencia 2](evidencias/evidencia_2_mysql.png) |
| Validación local, con limitaciones documentadas | [Reporte](verificacion/REPORTE_VALIDACION_LOCAL.md) |

También hay versiones PNG de los diagramas en `diagramas/` y un programa de comprobación local en `verificacion/`.

## Cómo ejecutar en MySQL Workbench

1. Conéctate a MySQL Server 8.0.16 o posterior.
2. Abre `sql/TecnoAyuda_Completo.sql` usando **File → Open SQL Script**.
3. Ejecuta todo el archivo.
4. Actualiza **SCHEMAS** y busca `tecnoayuda_entrega`.
5. Comprueba las 15 tablas y ejecuta las consultas de métricas.
6. Opcionalmente, ejecuta `sql/TecnoAyuda_Verificacion_Workbench.sql` para comprobaciones complementarias de solo lectura.

**Precaución:** el script principal elimina y vuelve a crear `tecnoayuda_entrega` al ejecutarse; no debe utilizarse si esa base contiene datos que deseas conservar.

## Temas cubiertos

**Parte A:** empresa y proceso comercial, recorrido y embudo de ventas, campañas, canales pagados y orgánicos, presupuesto, contenido con revisiones, traspaso a ventas, oportunidades, contratos, tablas relacionales, datos ficticios y métricas CPC, CTR, CAC, ROAS, conversiones, ciclo de venta y ticket promedio.

**Parte B:** propuesta conceptual de un agente orquestador y seis agentes especializados, con fichas, permisos, arquitectura y ejemplo de flujo. **No son agentes ejecutables implementados**.

## Estado de verificación y evidencias

- Hay una captura real de MySQL Workbench donde una consulta de campañas devuelve 10 registros.
- Hay otra captura real que confirma **15 tablas** en la base `tecnoayuda_entrega`.
- El informe publicado tiene portada con los datos académicos indicados y las evidencias anteriores.
- Las pruebas adicionales locales de integridad y métricas están documentadas en `verificacion/`. Esas pruebas locales **no sustituyen una ejecución en MySQL Server**.
- **Pendiente académico:** añadir capturas reales de los resultados de las otras consultas SQL (CPC, CTR, CAC, ROAS, tasas de conversión, ciclo de venta, ticket promedio y comparación de métricas de vanidad con métricas de negocio) para reforzar la evidencia de ejecución que pide el enunciado.

No se han generado imágenes falsas ni se declara que las consultas pendientes se hayan ejecutado en la computadora del estudiante.
