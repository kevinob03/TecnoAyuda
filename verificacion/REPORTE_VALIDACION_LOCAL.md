# Reporte de verificación local — TecnoAyuda

**Fecha:** 29 de octubre de 2026  
**Tipo de prueba:** ejecución de compatibilidad en SQLite, adaptando sintaxis MySQL y manteniendo restricciones y datos.  
**Importante:** esto **no demuestra** que el SQL se haya ejecutado en un servidor MySQL. La ejecución real y las capturas en MySQL Workbench permanecen pendientes.

## Resultados comprobados

| Comprobación | Resultado |
|---|---|
| Tablas creadas en el entorno de prueba | 15 |
| Registros mínimos por tabla | 15 de 15 tablas cumplen |
| Violaciones de llaves foráneas | 0 |
| Contratos ligados a oportunidades no ganadas | 0 |
| Contenidos publicados sin fecha de publicación | 0 |
| Campañas con asignaciones que no cuadran con presupuesto | 0 |
| Contratos firmados antes del registro del contacto | 0 |
| Consultas de métricas con resultados | 8 de 8 |
| Total de contratos de ejemplo | 10 |
| Ingresos ficticios totales | ₡1.750.000 |
| Gastos ficticios totales | ₡1.212.000 |

Consultas examinadas: **CPC, CTR, CAC, ROAS, conversiones entre etapas, ciclo de venta, ticket promedio y comparación de métricas de vanidad con negocio**. Las cifras son datos **inventados para fines académicos**, no resultados reales de TecnoAyuda.

## Cómo repetir esta prueba

Desde la carpeta principal del proyecto, ejecutar:

```bash
python verificacion/verificar_local.py
```

Solo necesita Python 3; el script utiliza una base SQLite temporal en memoria y **no altera archivos ni bases de datos de MySQL**.

## Pendientes de validación real

1. Ejecutar `sql/TecnoAyuda_Completo.sql` en **MySQL Server 8.0.16 o posterior**, desde Workbench.
2. Ejecutar `sql/TecnoAyuda_Verificacion_Workbench.sql` y revisar los resultados.
3. Guardar capturas auténticas del panel de tablas y las ocho consultas de métricas, sin alterar las imágenes.

Si MySQL devuelve algún error, **no publicar capturas como exitosas**: corregir primero la causa y volver a probar.
