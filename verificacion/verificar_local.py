#!/usr/bin/env python3
"""Prueba académica LOCAL usando SQLite compatible; NO ejecuta MySQL Server.

Desde la raíz del repositorio: python verificacion/verificar_local.py
"""
from __future__ import annotations
import datetime
import pathlib
import re
import sqlite3

ROOT = pathlib.Path(__file__).resolve().parents[1]
source = (ROOT / 'sql' / 'TecnoAyuda_Completo.sql').read_text(encoding='utf-8')

clean = re.sub(r'^--.*$', '', source, flags=re.M)
clean = re.sub(r'DROP DATABASE IF EXISTS tecnoayuda_entrega;', '', clean)
clean = re.sub(r'CREATE DATABASE tecnoayuda_entrega\s+CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;', '', clean)
clean = re.sub(r'USE tecnoayuda_entrega;', '', clean)
clean = clean.replace('INT AUTO_INCREMENT PRIMARY KEY', 'INTEGER PRIMARY KEY AUTOINCREMENT')
clean = clean.replace('ENGINE=InnoDB', '').replace('SHOW TABLES;', '')
clean = re.sub(r"SELECT COUNT\(\*\) AS total_tablas\s+FROM information_schema.tables\s+WHERE table_schema = 'tecnoayuda_entrega'\s+AND table_type = 'BASE TABLE';", '', clean)

conn = sqlite3.connect(':memory:')
conn.execute('PRAGMA foreign_keys=ON')
conn.create_function('DATEDIFF', 2, lambda a,b: (datetime.date.fromisoformat(a[:10]) - datetime.date.fromisoformat(b[:10])).days if a and b else None)
conn.executescript(clean)

count = conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name != 'sqlite_sequence'").fetchone()[0]
assert count == 15, f'Tablas: {count}, se esperaban 15'
assert not conn.execute('PRAGMA foreign_key_check').fetchall(), 'Existen referencias foráneas inválidas'

catalogs = {'empleados', 'servicios', 'canales'}
tables = ['empleados','servicios','canales','campanas','asignaciones_presupuesto','contenidos',
          'revisiones_contenido','contactos','historial_embudo','interacciones_contenido',
          'traspasos_ventas','oportunidades_venta','contratos','gastos','resultados_campana']
for table in tables:
    rows = conn.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0]
    expected = 5 if table in catalogs else 10
    assert rows >= expected, f'{table}: {rows} registros (mínimo {expected})'

checks = {
 'Contratos tienen oportunidades ganadas': "SELECT COUNT(*) FROM contratos co JOIN oportunidades_venta o ON co.id_oportunidad=o.id_oportunidad WHERE o.estado!='Ganada'",
 'Contenidos publicados tienen fecha': "SELECT COUNT(*) FROM contenidos WHERE estado='Publicado' AND fecha_publicacion IS NULL",
 'Campañas con presupuesto asignado distinto': "SELECT COUNT(*) FROM campanas c WHERE presupuesto_total != (SELECT SUM(monto_asignado) FROM asignaciones_presupuesto a WHERE a.id_campana=c.id_campana)",
 'Contratos firmados antes de registro del contacto': "SELECT COUNT(*) FROM contratos co JOIN oportunidades_venta o ON co.id_oportunidad=o.id_oportunidad JOIN contactos ct ON ct.id_contacto=o.id_contacto WHERE co.fecha_firma<date(ct.fecha_registro)",
}
for description, sql in checks.items():
    num = conn.execute(sql).fetchone()[0]
    assert num == 0, f'{description}: {num} discrepancias'

print('VALIDACIÓN LOCAL / COMPATIBILIDAD CON SQLITE (NO ES MYSQL)')
print('Tablas:', count)
print('Referencias foráneas inválidas: 0')
print('Mínimos de datos: 15/15 tablas correctas')
print('Inconsistencias adicionales:', sum(conn.execute(sql).fetchone()[0] for sql in checks.values()))

for i in range(1, 9):
    part = re.search(rf'-- CONSULTA {i}:.*?\n(.*?)(?=\n-- CONSULTA {i+1}:|\n-- CONSULTA EXTRA:)', source, re.S)
    assert part, f'No se encontró consulta {i}'
    sql_text = re.sub(r'^--.*$', '', part.group(1), flags=re.M).strip().split(';')[0].strip()
    cur = conn.execute(sql_text)
    rows = cur.fetchall()
    assert rows, f'Consulta {i} sin filas'
    print(f'Consulta {i}: {len(rows)} fila(s); columnas = {", ".join(x[0] for x in cur.description)}')

print('Gasto total CRC:', conn.execute('SELECT SUM(monto) FROM gastos').fetchone()[0])
print('Ingresos CRC:', conn.execute('SELECT SUM(monto_final) FROM contratos').fetchone()[0])
print('Contratos:', conn.execute('SELECT COUNT(*) FROM contratos').fetchone()[0])
print('RESULTADO: PRUEBAS LOCALES APROBADAS. FALTA EJECUTAR EN MYSQL WORKBENCH.')
