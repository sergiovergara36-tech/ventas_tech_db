-- ==============================================================================
-- Archivo: m5_consultas_joins.sql
-- Propósito: Consultas con JOINs adaptadas a la estructura real de Ventas_Tech_DB
-- ==============================================================================

USE Ventas_Tech_DB;
GO

-- ------------------------------------------------------------------------------
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- ------------------------------------------------------------------------------
SELECT 
    v.fecha_venta AS fecha,
    c.nombre AS nombre_cliente,
    'B2C' AS segmento,           
    c.ciudad AS region,          
    p.nombre_producto,
    cat.nombre_categoria AS categoria, 
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    'Online' AS canal            
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;


-- ------------------------------------------------------------------------------
-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- ------------------------------------------------------------------------------
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- ------------------------------------------------------------------------------
-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- ------------------------------------------------------------------------------
SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- ------------------------------------------------------------------------------
-- Consulta 4 — Consolidado por canal (UNION ALL)
-- ------------------------------------------------------------------------------
WITH ConsolidadoCanales AS (
    SELECT 
        id_venta,
        (cantidad * precio_unitario) AS total_venta,
        'Online' AS origen_canal
    FROM ventas
    WHERE id_venta <= 5
    
    UNION ALL
    
    SELECT 
        id_venta,
        (cantidad * precio_unitario) AS total_venta,
        'Presencial' AS origen_canal
    FROM ventas
    WHERE id_venta > 5
)
SELECT 
    origen_canal AS canal,
    SUM(total_venta) AS total_facturado
FROM ConsolidadoCanales
GROUP BY origen_canal;