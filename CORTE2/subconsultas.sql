
create database tiendaonline;
use tiendaonline;


create table departamento (
    iddepto     varchar(50) primary key,
    nombredepto varchar(50) not null
);

create table empleado (
    idempleado     int auto_increment primary key,
    nombreeempleado varchar(50) not null,
    deptoidfk      varchar(50) not null,
    salario        int(10),
    constraint fkdeptoemple
        foreign key (deptoidfk) references departamento(iddepto)
);

create table producto (
    idproducto     int auto_increment primary key,
    nombreproducto varchar(50) not null,
    precioproducto double      not null,
    categoria      varchar(50) not null
);

create table pedido (
    idpedido     int auto_increment primary key,
    preciototal  double not null,
    idempleadofk int(11) not null,
    constraint fkempleado
        foreign key (idempleadofk) references empleado(idempleado)
);

create table detallepedido (
    iddetalle    int auto_increment primary key,
    idpedidofk   int not null,
    idproductofk int not null,
    cantidad     int not null default 1,
    constraint fkdetalle_pedido
        foreign key (idpedidofk)   references pedido(idpedido),
    constraint fkdetalle_producto
        foreign key (idproductofk) references producto(idproducto)
);


insert into departamento (iddepto, nombredepto) values
('D001', 'tecnología'),
('D002', 'ventas'),
('D003', 'recursos humanos'),
('D004', 'logística'),
('D005', 'marketing'),
('D006', 'contabilidad'),
('D007', 'soporte técnico'),
('D008', 'compras'),
('D009', 'legal'),
('D010', 'gerencia');


insert into producto (nombreproducto, precioproducto, categoria) values
('audífonos inalámbricos',  50000,   'accesorios'),
('laptop hp',              1000000,  'tecnología'),
('iphone 14',              4000000,  'tecnología'),
('iphone 15',              2000000,  'tecnología'),
('samsung galaxy s23',     3500000,  'tecnología'),
('mouse inalámbrico',        45000,  'accesorios'),
('teclado mecánico',        180000,  'accesorios'),
('monitor 24"',             750000,  'tecnología'),
('silla ergonómica',        600000,  'muebles'),
('webcam hd',               120000,  'accesorios');


insert into empleado (nombreeempleado, deptoidfk, salario) values
('carlos ramírez',  'D001', 3500000),
('laura gómez',     'D002', 2800000),
('andrés torres',   'D003', 3000000),
('maría pérez',     'D004', 2600000),
('juan herrera',    'D005', 3200000),
('sofía martínez',  'D006', 2900000),
('diego lópez',     'D007', 3100000),
('valentina cruz',  'D008', 2750000),
('felipe morales',  'D009', 3800000),
('camila vargas',   'D010', 5000000);


insert into pedido (preciototal, idempleadofk) values
(100000,  2),
(1050000, 1),
(4000000, 3),
(135000,  4),
(225000,  2),
(1500000, 5),
(600000,  6),
(2050000, 7),
(120000,  8),
(3600000, 9);


insert into detallepedido (idpedidofk, idproductofk, cantidad) values
(1,  1, 2),  
(2,  2, 1),  
(3,  3, 1),  
(4,  6, 3),  
(5,  7, 1),  
(5,  6, 1),  
(6,  8, 2),  
(7,  9, 1),  
(8,  4, 1),  
(8,  1, 1),  
(9,  10, 1), 
(10, 5, 1);  

select
    p.idpedido,
    e.nombreeempleado  as empleado,
    p.preciototal,
    pr.nombreproducto  as producto,
    dp.cantidad
from pedido p
inner join empleado      e  on p.idempleadofk  = e.idempleado
inner join detallepedido dp on p.idpedido      = dp.idpedidofk
inner join producto      pr on dp.idproductofk = pr.idproducto;


use tiendaonline;

##procedimientos almacenados - funciones-vistas
/* procedimientod almacenados

son bloques de codigo de sql que tiene nombre que se almacenaen el servidor y se ejecutan
 con invocacion o llamandolos, pueden ser de registro, consulta, modificacion, actualizacion o eliminacion
 
 con parametros entrada, salida o ambos
 
 sintaxis
 crear procedimiento
 delimiter//
 create procedure  nombreProcedimiento( 
 in parametroEntrada tipo, 
 out parametroSalida tipo,
 inout parametroEntradaSalida tipo
 )
begin
--declaracion variables locales---
declare variable tipo default valor

--cuerpo del procedimiento--

sentencias sql, control de flujo...alter

end//
 delimiter;
 
 --invocar procedimiento 
 call nombre (valores de los parametro)
 ejemplo 1
 registro de pedido
 */
 
 Delimiter //
 
 create procedure crear_pedido(
 in p_idCliente int,
 in p_IdProducto int,
 in p_cantidad int,
 out p_id_pedido int,
 out p_mensaje varchar(2000)
 )
 
 begin 
 
 declare v_stock int;
 declare v_precio double;
 declare v_total double;
 -- mensaje de error--
 declare exit handler for SQLEXCEPTION
		begin 
			rollback;
            set p_mensaje="error: transaccion rechazada";
            set p_id_pedido=-1;
            end;
            
--
select 	stock,precio into v_stock, v_precio
from productos where idProducto=p_IdProducto;

if v_stock< cantidad then 
	set p_mensaje=concat("stockInsuficiente Disponible:", v_stock);
	set p_id_pedido=0;
else 
	start transaction;
	 set v_total= v_precio*p_cantidad;
	 
	 insert into pedidos(id_cliente, total) values(p_id_cliente, v_total);
	 set id_pedido= last_insert_id();
	 
	  insert into detallePedidos(id_pedido,idProducto, cantidad, precio_unit) values(p_id_pedido, p_cantidad, v_precio);
	  
	  update productos
	  set stock = stock-p_cantidad
	  where idProducto=p_id_producto;
	  commit;
	  set p_mensaje= concat("pedido #", p_id_pedido,"creado correctamente");
      end if;
      
end //

delimiter ;



 Delimiter //
 
 create procedure cancelar_pedido(
 in p_idCliente int,
 in p_IdProducto int,
 out p_mensaje varchar(2000)
 )
 
 begin 
 
 declare v_cantidad int;
 declare v_precio double;
 declare v_id_cliente int;
 declare v_estado_pedido varchar(50);
 -- mensaje de error--
 declare exit handler for SQLEXCEPTION
		begin 
			rollback;
            set p_mensaje="error: transaccion rechazada";
            set p_id_pedido=-1;
            end;
            
--
select 	cantidad into v_cantidad
from detallePedido where idpedidp=p_IdPedido;
select 	idCliente,estadoPedido into v_id_cliente, v_estado
from pedido where idpedidp=p_IdPedido;


if v_id_cliente != p_idCliente or v_estado="cancelado" then 
	set p_mensaje=concat("no se puede cancelar el pedido pedido ya cancelado o cliente no corresponde");
else 
	start transaction;
	  
	  update productos
	  set stock = stock+v_cantidad
	  where idProducto=p_id_producto;
       update pedido
	  set estado = "cancelado"
	  where idProducto=p_id_producto;
	  commit;
	  set p_mensaje= concat("pedido #", p_id_pedido,"cancelado correctamente");
      end if;
      
end //

delimiter ;
            
/* sintaxis de las funciones
delimiter //
create function nombre_funcion(
parametro1 tipo,
parametro2 tipo
)
returns tipo_retorno 
deterministic
now(), rand()
reads sql data
tablas 

begin 
	declare variable tipo
    ---logica---
    return variable;
	
end //

delimiter ;


*/
##calcular descuento

delimiter //
create function fn_descuento_volumen (p_cantidad int,
p_precio double)
returns double
deterministic
begin

declare v_porcentaje decimal(5,2);
declare v_total decimal(12,2);
-- definir el porcentaje de descuento segun la cantidad comprada
set v_porcentaje= case
	when p_cantidad>=100 then 20.00
    when p_cantidad>=50 then 15.00
    when p_cantidad>=20 then 10.00
	when p_cantidad>=10 then 5.00
    
end//

fn_clasificar_cliente
