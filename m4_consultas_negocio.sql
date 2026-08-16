USE Ventas_Tech_DB;
-- ==============================================================================
-- Archivo: m4_consultas_negocio.sql
-- Propósito: Extracción de métricas clave para el equipo comercial de RetailPro
-- Base de datos: Ventas_Tech_DB (Tabla: ventas)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
-- ------------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- ------------------------------------------------------------------------------
-- Consulta 2 — Ranking de productos
-- Top 5 de id_producto por total facturado, unidades vendidas y total generado.
-- ------------------------------------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;


-- ------------------------------------------------------------------------------
-- Consulta 3 — Clientes recurrentes
-- Clientes que hayan realizado más de un pedido, cantidad de pedidos y total gastado.
-- ------------------------------------------------------------------------------
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;


-- ------------------------------------------------------------------------------
-- Consulta 4 — Meses por encima/por debajo del promedio
-- Etiqueta con CASE WHEN comparando el mes contra el promedio mensual general.
-- ------------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE 
        WHEN SUM(cantidad * precio_unitario) > (
            -- Subconsulta para calcular el promedio general de todos los meses
            SELECT AVG(facturacion_mensual) 
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS facturacion_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS promedios
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_mensual
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- ==============================================================================
-- BLOQUE DE CIERRE: Hallazgos concretos del análisis
-- ==============================================================================
/*
Revisando los resultados arrojados por los datos iniciales de TechStore cargados en M3, podemos concluir que:

1. El producto estrella (id_producto = 1, Laptop Pro 15) concentra un altísimo porcentaje de la facturación total del trimestre, generando $2400 por sí solo.
2. Enero y febrero fueron meses muy fuertes que traccionaron la facturación hacia arriba, quedando ambos etiquetados como 'Por encima' del promedio, mientras que marzo experimentó una desaceleración.
3. Existe una excelente retención inicial: los 5 clientes registrados (id del 1 al 5) realizaron exactamente 2 pedidos cada uno en este primer trimestre, consolidándose todos como clientes recurrentes.
*/