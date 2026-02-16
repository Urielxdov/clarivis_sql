/*
===========================================================
MODEL STRUCTURAL HEALTH CHECK
-----------------------------------------------------------
Este query evalúa la "salud estructural" del modelo relacional.

Mide:

- Cobertura de PK
- Cobertura de FK
- Tablas aisladas
- Uso de índices secundarios
- Densidad estructural (columnas promedio)

La intención NO es auditoría funcional,
sino evaluación de madurez del diseño.

Todas las métricas se calculan a nivel tabla.
===========================================================
*/

-- Snapshot lógico de todas las tablas del modelo
WITH base_tables AS (
    SELECT object_id
    FROM sys.tables
),

-- Tablas que poseen PRIMARY KEY
pk_tables AS (
    SELECT DISTINCT parent_object_id AS object_id
    FROM sys.key_constraints
    WHERE type = 'PK'
),

-- Tablas que participan como origen de FOREIGN KEY
fk_tables AS (
    SELECT DISTINCT parent_object_id AS object_id
    FROM sys.foreign_keys
),

-- Tablas que poseen índices secundarios reales
-- (se excluyen PK, hipotéticos y heaps)
index_tables AS (
    SELECT DISTINCT object_id
    FROM sys.indexes
    WHERE is_primary_key = 0
      AND is_hypothetical = 0
      AND type > 0
),

-- Conteo de columnas por tabla
-- Usado como proxy de densidad estructural
column_count AS (
    SELECT object_id, COUNT(*) AS number_columns
    FROM sys.columns
    GROUP BY object_id
)

SELECT

    -- Total de tablas en el modelo
    COUNT(bt.object_id) AS total_tables,

    -- Tablas sin PK (riesgo de identidad lógica)
    SUM(CASE WHEN pk.object_id IS NULL THEN 1 ELSE 0 END) AS tables_without_pk,

    -- Tablas sin FK (posible aislamiento relacional)
    SUM(CASE WHEN fk.object_id IS NULL THEN 1 ELSE 0 END) AS tables_without_fk,

    -- Tablas con al menos una relación saliente
    SUM(CASE WHEN fk.object_id IS NOT NULL THEN 1 ELSE 0 END) AS tables_with_fk,

    -- Tablas sin índices secundarios (riesgo de performance)
    SUM(CASE WHEN idx.object_id IS NULL THEN 1 ELSE 0 END) AS tables_without_secondary_indexes,

    -- Promedio de columnas por tabla
    -- Aproxima complejidad estructural
    AVG(cc.number_columns * 1.0) AS avg_columns_per_table,

    -- % de tablas sin PK
    (SUM(CASE WHEN pk.object_id IS NULL THEN 1 ELSE 0 END) * 100.0) 
        / COUNT(bt.object_id) AS percentage_tables_without_pk,

    -- % de tablas sin FK
    (SUM(CASE WHEN fk.object_id IS NULL THEN 1 ELSE 0 END) * 100.0) 
        / COUNT(bt.object_id) AS percentage_tables_without_fk

FROM base_tables bt
LEFT JOIN pk_tables pk ON pk.object_id = bt.object_id
LEFT JOIN fk_tables fk ON fk.object_id = bt.object_id
LEFT JOIN index_tables idx ON idx.object_id = bt.object_id
LEFT JOIN column_count cc ON cc.object_id = bt.object_id;
