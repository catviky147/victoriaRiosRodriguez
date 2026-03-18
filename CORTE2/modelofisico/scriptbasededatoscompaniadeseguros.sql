## Victoria Rios Rodriguez
## query instruccion o peticion a la base de datos
/* 
lenguaje de definicion de datos DDL 
create -> crea datos
alter -> hacer relaciones o alteraciones
drop -> borrar tablas 
truncate -> modificar obligadamente 
definen datos
*/
## creacion de base de datos
create database companiaseguros;
## encender/ habailitar bases de datos "use nombre_base_de_datos"
use companiaseguros;

/* crear tablas
create table nombre_tabla (campo1 tipodato1 (tamano) restriccion, campo2 tipodato2 tamano restriccion);
*/

create table compania(
idcompania varchar (50) primary key, 
nit varchar (20) unique not null,
nombreCompania varchar (50) not null,
fehcafundacion date null,
representantelegal varchar (50) not null);
create table seguros(
idseguro varchar (50) primary key,
 estado varchar (20) not null,
 costo double not null,
 fehcainicio date not null,
 fechaexpiracion date not null,
 valorasegurado double not null,
 idcompaniaFK varchar (50) not null,
 idautomovilFK varchar (50) not null
 ## constraint FKCompaniaSeguros
 ##foreign key (idcompaniaFK)
##references compania(idcompania)
 );
 create table automovil (
 idauto varchar (50) primary key, 
 marca varchar (50) not null,
 modelo varchar (50) not null,
 tipo varchar (50) not null,
 anofabricacion int not null,
 serialchasis varchar (50) not null,
 pasajeros int not null,
 cilindraje double not null);
 create table detallesaccidente(
 iddetalle int primary key,
 idaccidenteFK varchar (50) not null,
 idautoFK varchar (50) not null);
 create table accidente(
 idaccidente varchar (50) primary key,
 fechaaccidente date not null,
 lugar varchar (50) not null,
 heridos int null,
 fatalidades int null,
 automotores int not null);

##Describir la estructura de las tablas describe nombre_tabla

describe seguros;
## relaciones
##opcion 1 crear la relacion al mismo tiempo que la tabla
##opcion 2 crear un alter table 

alter table seguros 
add constraint FKCompaniaSeguros
foreign key (idcompaniaFK)
references compania(idcompania);

alter table seguros 
add constraint FKautomovilSeguros
foreign key (idautomovilFK)
references automovil(idauto);

##agregar campo nuevo
alter table compania add direccionCompania varchar (50) not null;
describe compania;

##modificar un campo
 ##change alter table compania change nombreanterior nombrenuevo varchar (50) not null;
alter table compania change nit nitCompania varchar (11);

#cambiar nombre de un campo
alter table accidente change heridos numheridos int;
alter table accidente change numheridos numHeridos int;

## borrar el campo de una tabla quito el campo modelo de la tabla automovil
alter table automovil drop column modelo; 

##borrar llave foranea 
alter table seguros drop constraint FKautomovilSeguros;

## terminar de hacer las relaciones del ejercicio

alter table seguros 
add constraint FKautomovilSeguros
foreign key (idautomovilFK)
references automovil(idauto);

alter table  detallesaccidente
add constraint FKdetalleaccidenteAutomovil
foreign key (idautoFK)
references automovil(idauto);

alter table  detallesaccidente
add constraint FKdetalleaccidenteAccidente
foreign key (idaccidenteFK)
references accidente(idaccidente);

##borrar una tabla 
##drop table automovil;
##drop table seguros;




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



