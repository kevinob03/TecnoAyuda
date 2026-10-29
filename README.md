# TecnoAyuda — Business Solutions

Proyecto académico ficticio: **Primer Postejercicio de Business Solutions**, sobre mercadeo comercial en una empresa de servicios de soporte técnico.

## Entregables del profesor

| Entregable | Ubicación | Estado |
|---|---|---|
| Documento PDF con la Parte A, la Parte B y los diagramas | [`documentacion/TecnoAyuda_Informe_Final.pdf`](documentacion/TecnoAyuda_Informe_Final.pdf) | Preparado; portada sin datos personales |
| Código SQL, datos ficticios y consultas | [`sql/TecnoAyuda_Completo.sql`](sql/TecnoAyuda_Completo.sql) | Preparado; falta ejecución en servidor MySQL |
| Capturas reales de ejecución y consultas | [`evidencias/`](evidencias/) | **Pendientes** |

El documento Word en `documentacion/` es una copia editable del informe. En `diagramas/` se encuentran las fuentes editables y las imágenes de referencia.

## Organización

```text
tecnoayuda_github/
├── README.md
├── .gitignore
├── documentacion/
│   ├── TecnoAyuda_Informe_Final.pdf
│   └── TecnoAyuda_Informe_Final.docx
├── sql/
│   ├── TecnoAyuda_Completo.sql
│   └── TecnoAyuda_Verificacion_Workbench.sql
├── diagramas/
│   ├── TecnoAyuda_Diagrama_ER.drawio
│   ├── TecnoAyuda_ER_final.png
│   ├── TecnoAyuda_Embudo_Ventas.drawio
│   ├── TecnoAyuda_Embudo_Ventas.png
│   ├── TecnoAyuda_Arquitectura_Agentes.drawio
│   └── TecnoAyuda_Arquitectura_Agentes.png
├── verificacion/
│   ├── verificar_local.py
│   └── REPORTE_VALIDACION_LOCAL.md
└── evidencias/
    └── README.md
```

## Cómo ejecutar en MySQL Workbench

1. Conectarse a un servidor **MySQL 8.0.16 o posterior**.
2. Abrir `sql/TecnoAyuda_Completo.sql` con **File → Open SQL Script**.
3. Ejecutar el script completo y actualizar **SCHEMAS**.
4. Verificar que exista `tecnoayuda_entrega` con **15 tablas**.
5. Abrir y ejecutar `sql/TecnoAyuda_Verificacion_Workbench.sql` (solo lectura).
6. Ejecutar las ocho consultas de métricas al final del SQL principal y guardar las capturas siguiendo `evidencias/README.md`.

**Advertencia:** el archivo principal empieza con `DROP DATABASE IF EXISTS tecnoayuda_entrega`. Esto elimina y reconstruye únicamente esa base de datos; **no** ejecutarlo si contiene información que se deba conservar. No elimina la base separada `tecnoayuda`.

## Métricas incluidas

CPC, CTR, CAC, ROAS, conversión de lead a prospecto, prospecto a oportunidad y oportunidad a cierre, ciclo de venta, ticket promedio y comparación de métricas de vanidad con métricas de negocio.

## Agentes de inteligencia artificial

El informe **documenta** un agente orquestador y seis agentes especializados, sus permisos, tablas y flujos de trabajo. No existen agentes operativos ni integraciones externas implementadas en esta primera entrega.

## Verificación transparente

Las pruebas locales se realizaron utilizando **SQLite como motor de compatibilidad**, no un servidor MySQL. Ver el [reporte reproducible](verificacion/REPORTE_VALIDACION_LOCAL.md). Las capturas genuinas de Workbench siguen pendientes, y no deben reemplazarse por resultados simulados.

## Antes de la entrega final

Completar los datos del estudiante, carné y docente en la portada del PDF/Word; ejecutar en MySQL y añadir capturas auténticas. Los ejemplos y valores son ficticios, creados solo con fines académicos.