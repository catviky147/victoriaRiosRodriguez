
create database if not exists tiendaonline_v2;
use tiendaonline_v2;


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
    e.nombreeempleado  as cliente,
    p.preciototal,
    pr.nombreproducto  as producto,
    dp.cantidad
from pedido p
inner join empleado      e  on p.idempleadofk  = e.idempleado
inner join detallepedido dp on p.idpedido      = dp.idpedidofk
inner join producto      pr on dp.idproductofk = pr.idproducto;