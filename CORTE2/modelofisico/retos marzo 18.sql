#reto 1

create database tiendaonline;
use tiendaonline;

#reto 2

create table productos (idProducto varchar (50) primary key,
nompreProducto varchar (20) not null,
precio double not null,
stock int default 0,
fehcaCreacion datetime default current_timestamp);

alter table productos change idProducto idProducto int auto_increment;

##reto 3

create table cliente( idCliente varchar (50) primary key, nombre varchar (50) not null, email varchar (50) unique, telefono int (10) null);
create table pedido (idPedido varchar (50) primary key, 
idClienteFK varchar(50), fehca date default current_timestamp, total double,
constraint FKClientePedido
foreign key (idClienteFK)
references cliente(idCliente));

##reto 4

alter table productos add column categoria varchar (50) not null;
alter table cliente change telefono telefono varchar (15);
alter table pedido change total monto_total double;
alter table productos drop column fehcaCreacion; 

describe productos