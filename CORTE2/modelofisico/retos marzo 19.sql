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



SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;