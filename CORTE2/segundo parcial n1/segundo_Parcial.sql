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
 