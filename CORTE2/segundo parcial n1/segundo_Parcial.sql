-- =====================================================
-- DDL: CREACION DE BASE DE DATOS Y TABLAS
-- =====================================================
CREATE DATABASE tienda_tech CHARACTER SET utf8mb4;
USE tienda_tech;

CREATE TABLE clientes (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    ciudad          VARCHAR(60),
    fecha_registro  DATE DEFAULT (CURRENT_DATE)
);


CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria    VARCHAR(60),
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock        INT DEFAULT 0
);

CREATE TABLE pedidos (
    pedido_id    INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT NOT NULL,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL CHECK (cantidad > 0),
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    estado       VARCHAR(20) DEFAULT "pendiente"
        CHECK (estado IN ("pendiente","entregado","cancelado")),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- =====================================================
-- DML: DATOS DE PRUEBA
-- =====================================================
INSERT INTO clientes VALUES
 (1,"Ana Lopez","ana@mail.com","Bogota","2023-01-15"),
 (2,"Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"),
 (3,"Maria Torres","maria@mail.com","Cali","2023-05-10"),
 (4,"Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"),
 (5,"Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"),
 (6,"Luis Martinez","luis@mail.com","Bogota","2024-01-20"),
 (7,"Camila Vargas","camila@mail.com","Cali","2024-02-14"),
 (8,"Diego Morales","diego@mail.com","Medellin","2024-03-30");

INSERT INTO productos VALUES
 (1,"Laptop Pro 15","Computadores",3500000.00,12),
 (2,"Mouse Inalambrico","Perifericos",85000.00,50),
 (3,"Teclado Mecanico","Perifericos",220000.00,30),
 (4,"Monitor 27","Pantallas",1200000.00,8),
 (5,"Auriculares BT","Audio",350000.00,25),
 (6,"Webcam HD","Perifericos",180000.00,20),
 (7,"Disco SSD 1TB","Almacenamiento",420000.00,40),
 (8,"Tablet 10","Moviles",1800000.00,6);

INSERT INTO pedidos VALUES
 (1,1,1,1,"2024-01-10","entregado"),(2,1,2,2,"2024-01-15","entregado"),
 (3,2,3,1,"2024-02-05","entregado"),(4,2,5,1,"2024-02-20","cancelado"),
 (5,3,4,1,"2024-03-01","entregado"),(6,3,7,2,"2024-03-15","pendiente"),
 (7,4,2,3,"2024-04-02","entregado"),(8,4,6,1,"2024-04-10","pendiente"),
 (9,5,8,1,"2024-04-18","entregado"),(10,6,1,2,"2024-05-05","entregado"),
 (11,6,3,1,"2024-05-12","pendiente"),(12,7,5,2,"2024-05-20","entregado"),
 (13,1,7,1,"2024-06-01","entregado"),(14,8,4,1,"2024-06-10","cancelado"),
 (15,5,2,4,"2024-06-15","entregado"),(16,3,1,1,"2024-07-01","pendiente");

-- =====================================================
-- EJERCICIO 1: Agregar columna total_valor a la tabla pedidos
-- =====================================================

-- Opción 1: Columna calculada persistida (STORED)
ALTER TABLE pedidos 
ADD COLUMN total_valor DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * (SELECT precio FROM productos WHERE productos.producto_id = pedidos.producto_id)) STORED;

-- NOTA: Si la opción anterior no funciona en tu versión de MySQL, usa esta alternativa:
-- Alternativa: Agregar columna normal y luego actualizar con JOIN
/*
ALTER TABLE pedidos ADD COLUMN total_valor DECIMAL(12,2);

UPDATE pedidos p
JOIN productos pr ON p.producto_id = pr.producto_id
SET p.total_valor = p.cantidad * pr.precio;
*/

-- Crear índice sobre la columna estado
CREATE INDEX idx_estado ON pedidos(estado);

-- Verificar resultados del ejercicio 1
SELECT pedido_id, producto_id, cantidad, total_valor, estado FROM pedidos LIMIT 5;


-- =====================================================
-- EJERCICIO 2: Crear tabla log_cambios_estado y vista log_reciente
-- =====================================================

-- Crear tabla log_cambios_estado
CREATE TABLE log_cambios_estado (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    fecha_cambio DATETIME DEFAULT NOW(),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
);

-- Crear vista que muestra los últimos 10 registros
CREATE VIEW vista_log_reciente AS
SELECT 
    log_id,
    pedido_id,
    estado_anterior,
    estado_nuevo,
    fecha_cambio
FROM log_cambios_estado
ORDER BY fecha_cambio DESC
LIMIT 10;

-- Insertar algunos registros de ejemplo en log_cambios_estado
INSERT INTO log_cambios_estado (pedido_id, estado_anterior, estado_nuevo) VALUES
(2, 'entregado', 'cancelado'),
(4, 'pendiente', 'entregado'),
(6, 'pendiente', 'entregado'),
(8, 'pendiente', 'cancelado'),
(11, 'pendiente', 'entregado');

-- Verificar la vista
SELECT * FROM vista_log_reciente;


-- =====================================================
-- EJERCICIO 3: Operaciones en una misma sesión
-- =====================================================

-- (a) Insertar nuevo cliente
INSERT INTO clientes (nombre, email, ciudad, fecha_registro) 
VALUES ('Laura Rios', 'laura@mail.com', 'Manizales', CURRENT_DATE);

-- (b) Insertar pedido para ese cliente (producto_id=3, cantidad=2, estado=pendiente)
INSERT INTO pedidos (cliente_id, producto_id, cantidad, fecha_pedido, estado)
VALUES (
    (SELECT cliente_id FROM clientes WHERE email = 'laura@mail.com'),
    3,
    2,
    CURRENT_DATE,
    'pendiente'
);

-- (c) Actualizar stock del producto_id=3 (decrementar en 2)
UPDATE productos 
SET stock = stock - 2 
WHERE producto_id = 3;

-- (d) Consultar con JOIN el nombre del cliente, nombre del producto y estado del pedido recién creado
SELECT 
    c.nombre AS nombre_cliente,
    p.nombre AS nombre_producto,
    ped.estado,
    ped.cantidad,
    ped.fecha_pedido
FROM pedidos ped
JOIN clientes c ON ped.cliente_id = c.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
WHERE c.email = 'laura@mail.com'
  AND ped.producto_id = 3
  AND ped.cantidad = 2
ORDER BY ped.pedido_id DESC
LIMIT 1;

-- Verificar el stock actualizado del producto_id=3
SELECT producto_id, nombre, stock FROM productos WHERE producto_id = 3;

-- Verificar todos los pedidos del nuevo cliente
SELECT 
    ped.pedido_id,
    c.nombre AS cliente,
    p.nombre AS producto,
    ped.cantidad,
    ped.estado,
    ped.total_valor
FROM pedidos ped
JOIN clientes c ON ped.cliente_id = c.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
WHERE c.email = 'laura@mail.com';


-- =====================================================
-- CONSULTAS ADICIONALES PARA VERIFICAR TODO
-- =====================================================

-- Ver estructura actualizada de la tabla pedidos
DESCRIBE pedidos;

-- Ver todos los pedidos con su total_valor calculado
SELECT 
    ped.pedido_id,
    c.nombre AS cliente,
    p.nombre AS producto,
    ped.cantidad,
    p.precio,
    ped.total_valor,
    ped.estado
FROM pedidos ped
JOIN clientes c ON ped.cliente_id = c.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
ORDER BY ped.pedido_id;

-- Ver el índice creado en la tabla pedidos
SHOW INDEX FROM pedidos;

-- Ver estructura de la tabla log_cambios_estado
DESCRIBE log_cambios_estado;

-- Ver información de la vista
SHOW CREATE VIEW vista_log_reciente;

-- =====================================================
-- EJERCICIO 1: UPDATE con subconsulta correlacionada y DELETE con NOT EXISTS
-- =====================================================

-- Actualizar precio de productos cuyo stock es menor al promedio de stock de su misma categoría
UPDATE productos p1
SET precio = precio * 1.08
WHERE stock < (
    SELECT AVG(stock)
    FROM productos p2
    WHERE p2.categoria = p1.categoria
);

-- Eliminar pedidos cancelados cuyos clientes no tienen ningún otro pedido entregado
DELETE FROM pedidos
WHERE estado = 'cancelado'
AND NOT EXISTS (
    SELECT 1
    FROM pedidos p2
    WHERE p2.cliente_id = pedidos.cliente_id
    AND p2.pedido_id != pedidos.pedido_id
    AND p2.estado = 'entregado'
);

-- Verificar resultados
SELECT * FROM productos;
SELECT * FROM pedidos WHERE estado = 'cancelado';


-- =====================================================
-- EJERCICIO 2: JOIN tres tablas con subconsulta escalar
-- =====================================================

SELECT 
    c.nombre AS nombre_cliente,
    c.ciudad,
    p.nombre AS nombre_producto,
    ped.cantidad,
    ped.fecha_pedido,
    (ped.cantidad * p.precio) AS total
FROM pedidos ped
JOIN clientes c ON ped.cliente_id = c.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
WHERE ped.estado = 'entregado'
AND (ped.cantidad * p.precio) > (
    SELECT AVG(ped2.cantidad * p2.precio)
    FROM pedidos ped2
    JOIN productos p2 ON ped2.producto_id = p2.producto_id
    WHERE ped2.estado = 'entregado'
)
ORDER BY total DESC;


-- =====================================================
-- EJERCICIO 3: Vista con GROUP BY y consulta con filtro
-- =====================================================

CREATE VIEW vista_ventas_ciudad AS
SELECT 
    c.ciudad,
    COUNT(ped.pedido_id) AS total_pedidos_entregados,
    SUM(ped.cantidad * p.precio) AS suma_ingresos,
    AVG(ped.cantidad * p.precio) AS promedio_ingreso_por_pedido
FROM pedidos ped
JOIN clientes c ON ped.cliente_id = c.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
WHERE ped.estado = 'entregado'
GROUP BY c.ciudad;

-- Crear índice opcional para optimizar la vista
CREATE INDEX idx_estado_ciudad ON pedidos(estado, cliente_id);

-- Consultar la vista
SELECT * FROM vista_ventas_ciudad
WHERE suma_ingresos > 5000000
ORDER BY suma_ingresos DESC;


-- =====================================================
-- EJERCICIO 4: Vista con HAVING COUNT(DISTINCT)
-- =====================================================

CREATE VIEW vista_productos_populares AS
SELECT 
    p.producto_id,
    p.nombre,
    p.categoria,
    p.precio,
    COUNT(DISTINCT ped.cliente_id) AS total_clientes_distintos
FROM productos p
JOIN pedidos ped ON p.producto_id = ped.producto_id
WHERE ped.estado = 'entregado'
GROUP BY p.producto_id, p.nombre, p.categoria, p.precio
HAVING COUNT(DISTINCT ped.cliente_id) > 1;

-- Consultar productos de la categoría Perifericos
SELECT * FROM vista_productos_populares
WHERE categoria = 'Perifericos';


-- =====================================================
-- EJERCICIO 5: Función para ingreso total del cliente
-- =====================================================

DELIMITER //

CREATE FUNCTION fn_ingreso_cliente(p_cliente_id INT)
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE ingreso_total DECIMAL(15,2);
    
    SELECT COALESCE(SUM(ped.cantidad * p.precio), 0)
    INTO ingreso_total
    FROM pedidos ped
    JOIN productos p ON ped.producto_id = p.producto_id
    WHERE ped.cliente_id = p_cliente_id
    AND ped.estado = 'entregado';
    
    RETURN ingreso_total;
END//

DELIMITER ;

-- Usar la función en SELECT
SELECT 
    nombre,
    ciudad,
    fn_ingreso_cliente(cliente_id) AS ingreso_total
FROM clientes
ORDER BY ingreso_total DESC;


-- =====================================================
-- EJERCICIO 6: Función para verificar stock suficiente
-- =====================================================

DELIMITER //

CREATE FUNCTION fn_stock_suficiente(p_producto_id INT, p_cantidad_solicitada INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE stock_actual INT;
    
    SELECT stock INTO stock_actual
    FROM productos
    WHERE producto_id = p_producto_id;
    
    RETURN stock_actual >= p_cantidad_solicitada;
END//

DELIMITER ;

-- Consultar productos con menos de 5 unidades disponibles
SELECT 
    nombre,
    stock
FROM productos
WHERE fn_stock_suficiente(producto_id, 5) = 0;


-- =====================================================
-- EJERCICIO 7: Procedimiento para actualizar estado de pedido
-- =====================================================

DELIMITER //

CREATE PROCEDURE sp_actualizar_estado_pedido(
    IN p_pedido_id INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20);
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_pedido_existe INT;
    
    -- Verificar que el pedido exista
    SELECT COUNT(*) INTO v_pedido_existe
    FROM pedidos
    WHERE pedido_id = p_pedido_id;
    
    IF v_pedido_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El pedido no existe';
    ELSE
        -- Obtener estado actual y datos del pedido
        SELECT estado, producto_id, cantidad 
        INTO v_estado_actual, v_producto_id, v_cantidad
        FROM pedidos
        WHERE pedido_id = p_pedido_id;
        
        -- Insertar registro en log_cambios_estado
        INSERT INTO log_cambios_estado (pedido_id, estado_anterior, estado_nuevo)
        VALUES (p_pedido_id, v_estado_actual, p_nuevo_estado);
        
        -- Actualizar estado del pedido
        UPDATE pedidos
        SET estado = p_nuevo_estado
        WHERE pedido_id = p_pedido_id;
        
        -- Si el nuevo estado es cancelado, restaurar el stock
        IF p_nuevo_estado = 'cancelado' THEN
            UPDATE productos
            SET stock = stock + v_cantidad
            WHERE producto_id = v_producto_id;
        END IF;
    END IF;
END//

DELIMITER ;

-- Probar el procedimiento
CALL sp_actualizar_estado_pedido(4, 'entregado');
CALL sp_actualizar_estado_pedido(6, 'cancelado');


-- =====================================================
-- EJERCICIO 8: Vista de pedidos pendientes y procedimiento de alertas
-- =====================================================

CREATE VIEW vista_pedidos_pendientes AS
SELECT 
    ped.pedido_id,
    c.nombre AS nombre_cliente,
    p.nombre AS nombre_producto,
    ped.cantidad,
    p.precio AS precio_unitario,
    DATEDIFF(CURDATE(), ped.fecha_pedido) AS dias_espera
FROM pedidos ped
JOIN clientes c ON ped.cliente_id = c.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
WHERE ped.estado = 'pendiente';

DELIMITER //

CREATE PROCEDURE sp_alertar_retrasos(IN p_dias_limite INT)
BEGIN
    SELECT *
    FROM vista_pedidos_pendientes
    WHERE dias_espera > p_dias_limite
    ORDER BY dias_espera DESC;
END//

DELIMITER ;

-- Probar el procedimiento
CALL sp_alertar_retrasos(30);


-- =====================================================
-- EJERCICIO 9: Columna descuento y función precio final
-- =====================================================

-- Agregar columna descuento con CHECK
ALTER TABLE productos 
ADD COLUMN descuento DECIMAL(5,2) DEFAULT 0 
CHECK (descuento >= 0 AND descuento <= 50);

-- Actualizar algunos descuentos de ejemplo
UPDATE productos SET descuento = 10 WHERE producto_id IN (2, 5);
UPDATE productos SET descuento = 15 WHERE producto_id = 3;

DELIMITER //

CREATE FUNCTION fn_precio_final(p_producto_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE precio_original DECIMAL(10,2);
    DECLARE descuento_aplicado DECIMAL(5,2);
    DECLARE precio_final_calc DECIMAL(12,2);
    
    SELECT precio, descuento INTO precio_original, descuento_aplicado
    FROM productos
    WHERE producto_id = p_producto_id;
    
    SET precio_final_calc = precio_original * (1 - descuento_aplicado / 100);
    
    RETURN precio_final_calc;
END//

DELIMITER ;

-- Consultar los 3 productos con mayor precio final
SELECT 
    nombre,
    precio,
    descuento,
    fn_precio_final(producto_id) AS precio_final
FROM productos
ORDER BY precio_final DESC
LIMIT 3;


-- =====================================================
-- EJERCICIO 10: Procedimiento para registrar pedido completo
-- =====================================================

DELIMITER //

CREATE PROCEDURE sp_registrar_pedido(
    IN p_cliente_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_cliente_existe INT;
    DECLARE v_stock_actual INT;
    DECLARE v_nuevo_pedido_id INT;
    
    -- Validar que el cliente exista
    SELECT COUNT(*) INTO v_cliente_existe
    FROM clientes
    WHERE cliente_id = p_cliente_id;
    
    IF v_cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El cliente no existe';
    END IF;
    
    -- Validar stock suficiente
    SELECT stock INTO v_stock_actual
    FROM productos
    WHERE producto_id = p_producto_id;
    
    IF v_stock_actual < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Stock insuficiente';
    END IF;
    
    -- Insertar pedido
    INSERT INTO pedidos (cliente_id, producto_id, cantidad, estado)
    VALUES (p_cliente_id, p_producto_id, p_cantidad, 'pendiente');
    
    -- Obtener el ID del pedido recién creado
    SET v_nuevo_pedido_id = LAST_INSERT_ID();
    
    -- Actualizar stock
    UPDATE productos
    SET stock = stock - p_cantidad
    WHERE producto_id = p_producto_id;
    
    -- Retornar el pedido con JOIN
    SELECT 
        ped.pedido_id,
        c.nombre AS nombre_cliente,
        p.nombre AS nombre_producto,
        ped.cantidad,
        ped.estado,
        ped.fecha_pedido
    FROM pedidos ped
    JOIN clientes c ON ped.cliente_id = c.cliente_id
    JOIN productos p ON ped.producto_id = p.producto_id
    WHERE ped.pedido_id = v_nuevo_pedido_id;
    
END//

DELIMITER ;

-- Probar el procedimiento
CALL sp_registrar_pedido(1, 2, 3);


-- =====================================================
-- EJERCICIO 11: Función para clasificar productos y vista con clasificación
-- =====================================================

DELIMITER //

CREATE FUNCTION fn_clasificar_producto(p_producto_id INT)
RETURNS VARCHAR(10)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE precio_producto DECIMAL(10,2);
    DECLARE clasificacion VARCHAR(10);
    
    SELECT precio INTO precio_producto
    FROM productos
    WHERE producto_id = p_producto_id;
    
    CASE
        WHEN precio_producto > 1000000 THEN SET clasificacion = 'PREMIUM';
        WHEN precio_producto BETWEEN 200000 AND 1000000 THEN SET clasificacion = 'ESTANDAR';
        ELSE SET clasificacion = 'BASICO';
    END CASE;
    
    RETURN clasificacion;
END//

DELIMITER ;

CREATE VIEW vista_catalogo_clasificado AS
SELECT 
    nombre,
    categoria,
    precio,
    fn_clasificar_producto(producto_id) AS clasificacion,
    stock
FROM productos;

-- Consultar productos PREMIUM con stock > 5
SELECT * FROM vista_catalogo_clasificado
WHERE clasificacion = 'PREMIUM' AND stock > 5;


-- =====================================================
-- EJERCICIO 12: Vista clientes VIP con detalle de últimos pedidos
-- =====================================================

CREATE VIEW vista_clientes_vip AS
SELECT 
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COUNT(ped.pedido_id) AS total_pedidos_entregados
FROM clientes c
JOIN pedidos ped ON c.cliente_id = ped.cliente_id
WHERE ped.estado = 'entregado'
GROUP BY c.cliente_id, c.nombre, c.ciudad
HAVING COUNT(ped.pedido_id) > (
    SELECT AVG(total_pedidos)
    FROM (
        SELECT COUNT(*) AS total_pedidos
        FROM pedidos
        WHERE estado = 'entregado'
        GROUP BY cliente_id
    ) AS promedio_pedidos
);

-- Consulta para listar los últimos 2 pedidos de cada cliente VIP
SELECT 
    vip.nombre AS nombre_cliente,
    p.nombre AS nombre_producto,
    ped.fecha_pedido,
    ped.cantidad,
    ped.estado
FROM vista_clientes_vip vip
JOIN pedidos ped ON vip.cliente_id = ped.cliente_id
JOIN productos p ON ped.producto_id = p.producto_id
WHERE ped.estado = 'entregado'
AND (
    SELECT COUNT(*)
    FROM pedidos ped2
    WHERE ped2.cliente_id = vip.cliente_id
    AND ped2.estado = 'entregado'
    AND ped2.fecha_pedido >= ped.fecha_pedido
) <= 2
ORDER BY vip.nombre, ped.fecha_pedido DESC;


-- =====================================================
-- CONSULTAS DE VERIFICACIÓN FINAL
-- =====================================================

-- Verificar todas las vistas creadas
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Verificar todas las funciones
SHOW FUNCTION STATUS WHERE Db = DATABASE();

-- Verificar todos los procedimientos
SHOW PROCEDURE STATUS WHERE Db = DATABASE();

-- Verificar cambios en productos
SELECT producto_id, nombre, precio, stock, descuento FROM productos;

-- Verificar logs de cambios
SELECT * FROM log_cambios_estado ORDER BY fecha_cambio DESC;
 