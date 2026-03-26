##sentencias de manipulacion de datos

## agregar registros insert	
## modificar update
##consultas select 
## eliminar delete


create database if not exists tiendaOnline;
use tiendaOnline;

create table clientes(
idCliente int primary key auto_increment,
nombreCliente varchar(100) not null,
emailCliente varchar(150) unique,
ciudad varchar(80) null,
creado_en datetime default now()
);

create table productos(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
stockProducto int default 0,
categoriaProducto varchar(60)
);

create table pedido(
idPedido int primary key auto_increment,
cantidadProducto int not null,
fechaPedido date,
idClienteFK int,
idProductoFK int,
foreign key (idClienteFK) references clientes(idCliente),
foreign key (idProductoFK) references productos(idProducto)
);

create table cliente_cbackup (
idClienBack int primary key auto_increment,
nombreCliente varchar(100) ,
emailCliente varchar(150),
copiado_en datetime default now()
);
-- select consulta general de las tablas 
select * from clientes;

select * from productos;

select * from pedido;

-- Agregar 1 registro
describe clientes;
insert into clientes(idCliente,nombreCliente,emailCliente,ciudad) values ('','Ana Garcia','ana@mail.com','Madrid');
insert into clientes(nombreCliente,emailCliente,ciudad) values ('Pedro Perez','pedro@mail.com','Barcelona');
 select * from clientes;
-- Agregar Varios registros
describe productos;
insert into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Laptop Pro',1200000,15,'Electrónica'), 
('Mouse USB',50000,80,'Accesorios'),
('Monitor 32"',500000,20,'Electrónica'),
('Teclados',100000,35,'Accesorios');

select * from productos;

insert into cliente_backup (nombreCliente,emailCliente)
select nombreCliente,emailCliente
from clientes
where creado_en<'2026-03-20';

rename table cliente_cbackup to cliente_backup;

select * from cliente_backup;

describe cliente_backup;

select * from clientes;
-- Actualizar un campo
update clientes
set ciudad='Valencia'
where idCliente=1;

-- Actualizar varios campos
select * from productos;

update productos
set
precioProducto=1099000,
stockProducto=10
where idProducto=1;

update productos
set precioProducto=precioProducto * 1.10
where categoriaProducto='Accesorios';

-- delete eliminar registro  Where 

-- investigar los metodos de tipo numericos y caracteres en MySQL
-- investigar si se puede o no revertir una eliminacion de registros pista rollback csi se puede como
-- delete from nombre_tabla where condicion

select * from clientes;
delete from clientes 
where idCliente=2;

select * from productos;
delete from productos
where stockProducto=0 AND categoriaProducto='Descatalogado';

##NSERT
##1. Inserta 3 clientes nuevos con nombre, email y ciudad
insert into clientes(idCliente,nombreCliente,emailCliente,ciudad) values ('','Mario Vargas','Mario@mail.com','estocolmo'),
('','Isabela Ardila','isabela@mail.com','Cali'),
('','Amalia Segura','amalia@mail.com','Edimburgo');
##2. Inserta 2 productos con nombre, precio, stock y categoría
insert into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Teclado inalambrico',120000,20,'Accesorios'), 
('Audifonos con cable',10000,80,'Accesorios');
##3. Inserta 1 pedido vinculando un cliente y un producto recién creados
insert into pedidos (idClienteFK, idProductoFK) values (3,5);
##UPDATE 
##4. Cambia la ciudad de uno de tus clientes insertados
select * from clientes;
update clientes
set ciudad='Cartagena'
where idCliente=3;
##5. Aumenta en 5 unidades el stock de uno de tus productos
select * from productos;
update productos
set
stockProducto=stockProducto+5
where idProducto=5;
##6. Modifica el precio del segundo producto aplicando un descuento del 10%
select * from productos;
update productos
set
precioProducto=precioProducto* 0.1
where idProducto=2;
##DELETE
##7. Elimina el pedido que creaste en el punto 3
select * from pedido;
delete from pedido 
where idPedido=1;
##8. Elimina el cliente cuya ciudad cambiaste en el punto 4
select * from clientes;
delete from clientes 
where ciudad='Cartagena';
##9. Elimina todos los productos con stock menor a 3
select * from productos;
delete from productos 
where stockProducto<3;

##sentencia para la consulta
##SELECT para consultar
##consultas generales (todos los datos o campos de una tabla) select * /[campos]from [nombre de la tabla]
##consultas especificas alias/ calusula where/likes/subconsulta/multitabla/operaciones calculadas/ agrupadas/ ordenadas

describe productos;
alter table productos
change stockProducto stoProdT int;

select nombreProducto,stoProdT from productos;
select nombreProducto as Nombre_Producto,stoProdT as Stock from productos;
select nombreProducto as Nombre_Producto,stoProdT as Stock  where idProducto=1;
select nombreProducto as Nombre_Producto,stoProdT as Stock  where stoProdT>15 and idProducto=1;
select nombreProducto as Nombre_Producto,stoProdT as Stock
from productos order by stoProdT ASC;
select nombreProducto as Nombre_Producto,stoProdT as Stock
from productos order by stoprodT DESC;
select nombreProducto as Nombre_Producto,stoProdT as Stock where stoProdT>25 or idProducto=1;

select nombreProducto as Nombre_Producto, precioProducto as precio 
from productos where precioProducto between 50000 and 100000 order by precio asc; 

## like buscar que inicie/termine/ o contenga
##inicie
select * from productos where nombreProducto like "mo%";
##contenga
select * from productos where nombreProducto like "%o%";
##termina
select * from productos where nombreProducto not like "%s";

##insercion de csv

LOAD DATA INFILE "C:\Users\Desik\Downloads\clientes.csv"
INTO TABLE clientes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\Users\Desik\Documents\Universidad\2026-1\Ingieneria de datos\victoriaRiosRodriguez\CORTE2\csv script tienda online\productos.csv"
INTO TABLE productos
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\Users\Desik\Documents\Universidad\2026-1\Ingieneria de datos\victoriaRiosRodriguez\CORTE2\csv script tienda online\pedidos.csv"
INTO TABLE pedidos 
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\Users\Desik\Documents\Universidad\2026-1\Ingieneria de datos\victoriaRiosRodriguez\CORTE2\csv script tienda online\backup.csv"
INTO TABLE cliente_cbackup
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


##metodos de enteros

## round para redondear decimales
SELECT nombreProducto, ROUND(precioProducto, 0) AS precioRedondeado
FROM productos;

## sumar y sacar promedio
SELECT categoriaProducto,
       SUM(stockProducto) AS totalStock,
       AVG(precioProducto) AS precioPromedio
FROM productos
GROUP BY categoriaProducto;

##metodos de string 

## upper pone el dato en mayusculas length para saber la cantidad de caracteres
SELECT UPPER(nombreCliente) AS nombreMayusculas,
       LENGTH(nombreCliente) AS cantidadCaracteres
FROM clientes;

## substring y locate para generar un substring
SELECT nombreCliente,
       SUBSTRING(emailCliente, LOCATE('@', emailCliente) + 1) AS dominio
FROM clientes;
use tiendaOnline;


##enunciado subconsultas
##Mostrar los clientes que han realizado al menos dos pedido de un producto cuyo precio sea mayor a $100.000.

##enunciado consultas multitabla
##Mostrar el nombre del cliente, la fecha del pedido, el nombre del producto que pidió y la cantidad, para todos los pedidos registrados.

SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;