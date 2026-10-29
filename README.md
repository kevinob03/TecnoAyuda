# TecnoAyuda — Business Solutions

Proyecto académico ficticio de mercadeo comercial para una empresa de soporte técnico.

**Estudiante:** Kevin Ortiz Bolaños  
**Programa:** Full Stack — Forward Costa Rica  
**Módulo:** Business Solutions  
**Profesor:** Steven Salas Ledezma  
**Fecha:** 29 de octubre de 2026

## Estado de publicación

En este repositorio están publicados y verificados:
- [Script SQL completo](sql/TecnoAyuda_Completo.sql), que crea la base `tecnoayuda_entrega`, sus 15 tablas, datos ficticios y consultas.
- [Diagrama entidad-relación editable](diagramas/TecnoAyuda_Diagrama_ER.drawio).
- [Embudo de ventas editable](diagramas/TecnoAyuda_Embudo_Ventas.drawio).
- [Arquitectura de agentes editable](diagramas/TecnoAyuda_Arquitectura_Agentes.drawio).

**Pendiente de subir:** informe actualizado en PDF y DOCX, imágenes PNG de los diagramas, capturas de pantalla reales de MySQL y documentos auxiliares de validación. Estos archivos están preparados en el paquete descargable de ChatGPT, pero no forman parte todavía del repositorio. No se deben presentar como publicados.

## Uso en MySQL Workbench

1. Abrir `sql/TecnoAyuda_Completo.sql` mediante *File > Open SQL Script*.
2. Ejecutar el script completo en MySQL Server 8.0.16 o posterior.
3. Actualizar *SCHEMAS* y comprobar que `tecnoayuda_entrega` tenga 15 tablas.
4. Revisar el resultado de las consultas finales y guardar las capturas auténticas.

**Cuidado:** al ejecutarse de nuevo, el script elimina y recrea la base `tecnoayuda_entrega`. No lo ejecutes si deseas conservar datos de esa base.

## Alcance

La Parte A aborda campañas, canales, contenidos, aprobaciones, contactos, embudo de ventas, traspasos, oportunidades, contratos y métricas CPC, CTR, CAC, ROAS, conversión, ciclo de venta y ticket promedio. La Parte B describe un agente orquestador y seis agentes especializados de manera conceptual; **no se implementaron agentes operativos**.

## Evidencias y límites de validación

Se dispone de dos capturas reales proporcionadas por el estudiante: una consulta de presupuestos con 10 filas y una consulta que confirmó 15 tablas en MySQL Workbench. Eso no demuestra por sí solo que todas las consultas funcionen; el resto de verificaciones debe documentarse antes de afirmar que la ejecución fue integral.
