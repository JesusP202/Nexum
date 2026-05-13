-- ============================================================================
-- NEXUM - SISTEMA CRM INTEGRAL
-- Base de Datos: Oracle Database
-- Descripción: Sistema de Comercialización de Hardware y Equipos de Red
-- Autor: Proyecto Final BD II
-- Fecha: 2026
-- ============================================================================

-- ============================================================================
-- 1. CREAR ESQUEMA Y SECUENCIAS
-- ============================================================================

-- Eliminar tablas existentes (si las hay)

-- BEGIN
--    FOR cur_rec IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('TABLE', 'SEQUENCE', 'TRIGGER', 'PROCEDURE', 'PACKAGE'))
--    LOOP
--       IF cur_rec.object_type = 'TABLE' THEN
--          EXECUTE IMMEDIATE 'DROP TABLE ' || cur_rec.object_name || ' CASCADE CONSTRAINTS';
--       ELSIF cur_rec.object_type = 'SEQUENCE' THEN
--          EXECUTE IMMEDIATE 'DROP SEQUENCE ' || cur_rec.object_name;
--       ELSIF cur_rec.object_type = 'TRIGGER' THEN
--          EXECUTE IMMEDIATE 'DROP TRIGGER ' || cur_rec.object_name;
--       ELSIF cur_rec.object_type = 'PROCEDURE' THEN
--          EXECUTE IMMEDIATE 'DROP PROCEDURE ' || cur_rec.object_name;
--       ELSIF cur_rec.object_type = 'PACKAGE' THEN
--          EXECUTE IMMEDIATE 'DROP PACKAGE ' || cur_rec.object_name;
--       END IF;
--    END LOOP;
-- END;
-- /

-- Crear secuencias para generación de IDs
CREATE SEQUENCE seq_usuario START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_zona START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_categoria START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_producto START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_inventario START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_pedido START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_detalle_pedido START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_factura START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_visita_cliente START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_cuentas_pagar START WITH 1 INCREMENT BY 1 NOCACHE;

-- ============================================================================
-- 2. TABLAS MAESTRAS - USUARIOS Y ROLES
-- ============================================================================

CREATE TABLE roles (
    rol_id NUMBER PRIMARY KEY,
    nombre_rol VARCHAR2(50) NOT NULL UNIQUE,
    descripcion VARCHAR2(200),
    fecha_creacion TIMESTAMP DEFAULT SYSTIMESTAMP
);

INSERT INTO roles VALUES (1, 'ADMINISTRADOR', 'Acceso total al sistema', SYSTIMESTAMP);
INSERT INTO roles VALUES (2, 'GERENTE_VENTAS', 'Gestión de pedidos y ventas', SYSTIMESTAMP);
INSERT INTO roles VALUES (3, 'CLIENTE', 'Cliente que realiza compras', SYSTIMESTAMP);
INSERT INTO roles VALUES (4, 'SOPORTE', 'Personal de soporte técnico', SYSTIMESTAMP);

CREATE TABLE usuarios (
    usuario_id NUMBER PRIMARY KEY,
    email VARCHAR2(100) NOT NULL UNIQUE,
    nombre_usuario VARCHAR2(50) NOT NULL UNIQUE,
    contraseña VARCHAR2(255) NOT NULL,
    nombre_completo VARCHAR2(150) NOT NULL,
    telefono VARCHAR2(15),
    rol_id NUMBER NOT NULL REFERENCES roles(rol_id),
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    fecha_creacion TIMESTAMP DEFAULT SYSTIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol_id);

-- ============================================================================
-- 3. TABLAS MAESTRAS - GEOLOCALIZACIÓN Y VENTAS
-- ============================================================================

CREATE TABLE zonas (
    zona_id NUMBER PRIMARY KEY,
    nombre_zona VARCHAR2(100) NOT NULL UNIQUE,
    descripcion VARCHAR2(200),
    latitud NUMBER(10, 8),
    longitud NUMBER(11, 8),
    codigo_region VARCHAR2(10),
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    fecha_creacion TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_zonas_activo ON zonas(activo);

CREATE TABLE clientes (
    cliente_id NUMBER PRIMARY KEY,
    usuario_id NUMBER NOT NULL REFERENCES usuarios(usuario_id),
    zona_id NUMBER NOT NULL REFERENCES zonas(zona_id),
    razon_social VARCHAR2(200) NOT NULL,
    rfc VARCHAR2(13),
    direccion VARCHAR2(300) NOT NULL,
    ciudad VARCHAR2(100),
    estado VARCHAR2(100),
    codigo_postal VARCHAR2(10),
    latitud NUMBER(10, 8),
    longitud NUMBER(11, 8),
    credito_disponible NUMBER(12, 2) DEFAULT 0,
    limite_credito NUMBER(12, 2) DEFAULT 0,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    fecha_creacion TIMESTAMP DEFAULT SYSTIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_clientes_usuario ON clientes(usuario_id);
CREATE INDEX idx_clientes_zona ON clientes(zona_id);
CREATE INDEX idx_clientes_activo ON clientes(activo);

-- ============================================================================
-- 4. TABLAS MAESTRAS - CATÁLOGO DE PRODUCTOS
-- ============================================================================

CREATE TABLE categorias (
    categoria_id NUMBER PRIMARY KEY,
    nombre_categoria VARCHAR2(100) NOT NULL UNIQUE,
    descripcion VARCHAR2(300),
    tipo_producto VARCHAR2(50) NOT NULL,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    fecha_creacion TIMESTAMP DEFAULT SYSTIMESTAMP,
    CHECK (tipo_producto IN ('COMPUTACION', 'INFRAESTRUCTURA_RED', 'COMPONENTES'))
);

INSERT INTO categorias (categoria_id, nombre_categoria, tipo_producto, descripcion) 
VALUES (seq_categoria.NEXTVAL, 'Laptops', 'COMPUTACION', 'Computadoras portátiles de alta gama');

INSERT INTO categorias (categoria_id, nombre_categoria, tipo_producto, descripcion) 
VALUES (seq_categoria.NEXTVAL, 'PCs de Escritorio', 'COMPUTACION', 'Computadoras de escritorio profesionales');

INSERT INTO categorias (categoria_id, nombre_categoria, tipo_producto, descripcion) 
VALUES (seq_categoria.NEXTVAL, 'Switches', 'INFRAESTRUCTURA_RED', 'Switches de red gestionados');

INSERT INTO categorias (categoria_id, nombre_categoria, tipo_producto, descripcion) 
VALUES (seq_categoria.NEXTVAL, 'Routers', 'INFRAESTRUCTURA_RED', 'Routers empresariales de alto rendimiento');

INSERT INTO categorias (categoria_id, nombre_categoria, tipo_producto, descripcion) 
VALUES (seq_categoria.NEXTVAL, 'Discos SSD', 'COMPONENTES', 'Unidades de almacenamiento SSD de alta velocidad');

INSERT INTO categorias (categoria_id, nombre_categoria, tipo_producto, descripcion) 
VALUES (seq_categoria.NEXTVAL, 'Periféricos', 'COMPONENTES', 'Accesorios y periféricos de computación');

CREATE INDEX idx_categorias_activo ON categorias(activo);
CREATE INDEX idx_categorias_tipo ON categorias(tipo_producto);

CREATE TABLE productos (
    producto_id NUMBER PRIMARY KEY,
    categoria_id NUMBER NOT NULL REFERENCES categorias(categoria_id),
    nombre_producto VARCHAR2(200) NOT NULL,
    descripcion VARCHAR2(500),
    modelo VARCHAR2(100),
    marca VARCHAR2(100),
    precio_unitario NUMBER(12, 2) NOT NULL,
    costo_unitario NUMBER(12, 2) NOT NULL,
    especificaciones CLOB,
    foto_url VARCHAR2(500),
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    fecha_creacion TIMESTAMP DEFAULT SYSTIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_nombre ON productos(nombre_producto);

-- ============================================================================
-- 5. TABLAS DE INVENTARIO
-- ============================================================================

CREATE TABLE inventario (
    inventario_id NUMBER PRIMARY KEY,
    producto_id NUMBER NOT NULL REFERENCES productos(producto_id),
    zona_id NUMBER NOT NULL REFERENCES zonas(zona_id),
    cantidad_disponible NUMBER(10, 0) DEFAULT 0 NOT NULL,
    cantidad_reservada NUMBER(10, 0) DEFAULT 0 NOT NULL,
    cantidad_minima NUMBER(10, 0) DEFAULT 5 NOT NULL,
    fecha_ultimo_ajuste TIMESTAMP DEFAULT SYSTIMESTAMP,
    CHECK (cantidad_disponible >= 0 AND cantidad_reservada >= 0)
);

CREATE UNIQUE INDEX idx_inventario_unique ON inventario(producto_id, zona_id);
CREATE INDEX idx_inventario_zona ON inventario(zona_id);
CREATE INDEX idx_inventario_disponible ON inventario(cantidad_disponible);

CREATE TABLE movimientos_inventario (
    movimiento_id NUMBER PRIMARY KEY,
    inventario_id NUMBER NOT NULL REFERENCES inventario(inventario_id),
    tipo_movimiento VARCHAR2(50) NOT NULL,
    cantidad NUMBER(10, 0) NOT NULL,
    usuario_id NUMBER NOT NULL REFERENCES usuarios(usuario_id),
    motivo VARCHAR2(300),
    fecha_movimiento TIMESTAMP DEFAULT SYSTIMESTAMP,
    CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'AJUSTE', 'RESERVA', 'CANCELACION_RESERVA'))
);

CREATE INDEX idx_movimientos_inventario ON movimientos_inventario(inventario_id);
CREATE INDEX idx_movimientos_usuario ON movimientos_inventario(usuario_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento);

-- ============================================================================
-- 6. TABLAS DE PEDIDOS Y ÓRDENES
-- ============================================================================

CREATE TABLE estado_pedido (
    estado_id NUMBER PRIMARY KEY,
    nombre_estado VARCHAR2(50) NOT NULL UNIQUE,
    descripcion VARCHAR2(200)
);

INSERT INTO estado_pedido VALUES (1, 'PENDIENTE', 'Pedido creado, pendiente de confirmación');
INSERT INTO estado_pedido VALUES (2, 'CONFIRMADO', 'Pedido confirmado, reserva realizada');
INSERT INTO estado_pedido VALUES (3, 'PROCESANDO', 'Pedido en proceso de preparación');
INSERT INTO estado_pedido VALUES (4, 'ENVIADO', 'Pedido enviado al cliente');
INSERT INTO estado_pedido VALUES (5, 'ENTREGADO', 'Pedido entregado al cliente');
INSERT INTO estado_pedido VALUES (6, 'CANCELADO', 'Pedido cancelado');
INSERT INTO estado_pedido VALUES (7, 'DEVUELTO', 'Pedido devuelto por el cliente');

CREATE TABLE pedidos (
    pedido_id NUMBER PRIMARY KEY,
    cliente_id NUMBER NOT NULL REFERENCES clientes(cliente_id),
    usuario_id NUMBER REFERENCES usuarios(usuario_id),
    estado_id NUMBER NOT NULL REFERENCES estado_pedido(estado_id),
    zona_id NUMBER NOT NULL REFERENCES zonas(zona_id),
    numero_pedido VARCHAR2(20) NOT NULL UNIQUE,
    subtotal NUMBER(12, 2) NOT NULL,
    impuesto NUMBER(12, 2) NOT NULL,
    total NUMBER(12, 2) NOT NULL,
    notas VARCHAR2(500),
    fecha_pedido TIMESTAMP DEFAULT SYSTIMESTAMP,
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    fecha_modificacion TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_estado ON pedidos(estado_id);
CREATE INDEX idx_pedidos_zona ON pedidos(zona_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);

CREATE TABLE detalles_pedido (
    detalle_pedido_id NUMBER PRIMARY KEY,
    pedido_id NUMBER NOT NULL REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    producto_id NUMBER NOT NULL REFERENCES productos(producto_id),
    cantidad NUMBER(10, 0) NOT NULL,
    precio_unitario NUMBER(12, 2) NOT NULL,
    subtotal NUMBER(12, 2) NOT NULL,
    descuento_porcentaje NUMBER(5, 2) DEFAULT 0,
    descuento_monto NUMBER(12, 2) DEFAULT 0,
    total_linea NUMBER(12, 2) NOT NULL,
    CHECK (cantidad > 0)
);

CREATE INDEX idx_detalles_pedido_pedido ON detalles_pedido(pedido_id);
CREATE INDEX idx_detalles_pedido_producto ON detalles_pedido(producto_id);

-- ============================================================================
-- 7. TABLAS DE FACTURACIÓN Y CUENTAS POR PAGAR
-- ============================================================================

CREATE TABLE facturas (
    factura_id NUMBER PRIMARY KEY,
    pedido_id NUMBER NOT NULL REFERENCES pedidos(pedido_id),
    cliente_id NUMBER NOT NULL REFERENCES clientes(cliente_id),
    numero_factura VARCHAR2(20) NOT NULL UNIQUE,
    folio_fiscal VARCHAR2(50),
    subtotal NUMBER(12, 2) NOT NULL,
    impuesto NUMBER(12, 2) NOT NULL,
    total NUMBER(12, 2) NOT NULL,
    fecha_factura TIMESTAMP DEFAULT SYSTIMESTAMP,
    fecha_vencimiento DATE NOT NULL,
    estado_factura VARCHAR2(50) DEFAULT 'PENDIENTE',
    pdf_url VARCHAR2(500),
    CHECK (estado_factura IN ('PENDIENTE', 'PAGADA', 'CANCELADA', 'VENCIDA'))
);

CREATE INDEX idx_facturas_cliente ON facturas(cliente_id);
CREATE INDEX idx_facturas_pedido ON facturas(pedido_id);
CREATE INDEX idx_facturas_estado ON facturas(estado_factura);
CREATE INDEX idx_facturas_fecha ON facturas(fecha_factura);

CREATE TABLE cuentas_pagar (
    cuenta_pagar_id NUMBER PRIMARY KEY,
    factura_id NUMBER NOT NULL REFERENCES facturas(factura_id),
    cliente_id NUMBER NOT NULL REFERENCES clientes(cliente_id),
    monto_original NUMBER(12, 2) NOT NULL,
    monto_pagado NUMBER(12, 2) DEFAULT 0,
    monto_pendiente NUMBER(12, 2) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado_pago VARCHAR2(50) DEFAULT 'PENDIENTE',
    fecha_primer_aviso DATE,
    fecha_segundo_aviso DATE,
    dias_atraso NUMBER(4, 0) DEFAULT 0,
    fecha_registro TIMESTAMP DEFAULT SYSTIMESTAMP,
    CHECK (estado_pago IN ('PENDIENTE', 'PAGADA', 'VENCIDA', 'EN_COBRANZA'))
);

CREATE INDEX idx_cuentas_pagar_cliente ON cuentas_pagar(cliente_id);
CREATE INDEX idx_cuentas_pagar_estado ON cuentas_pagar(estado_pago);
CREATE INDEX idx_cuentas_pagar_vencimiento ON cuentas_pagar(fecha_vencimiento);

CREATE TABLE pagos (
    pago_id NUMBER PRIMARY KEY,
    cuenta_pagar_id NUMBER NOT NULL REFERENCES cuentas_pagar(cuenta_pagar_id),
    monto_pagado NUMBER(12, 2) NOT NULL,
    forma_pago VARCHAR2(50) NOT NULL,
    referencia_pago VARCHAR2(100),
    fecha_pago TIMESTAMP DEFAULT SYSTIMESTAMP,
    usuario_registro NUMBER NOT NULL REFERENCES usuarios(usuario_id),
    CHECK (forma_pago IN ('EFECTIVO', 'TRANSFERENCIA', 'CHEQUE', 'TARJETA_CREDITO', 'TARJETA_DEBITO'))
);

CREATE INDEX idx_pagos_cuenta ON pagos(cuenta_pagar_id);
CREATE INDEX idx_pagos_fecha ON pagos(fecha_pago);

-- ============================================================================
-- 8. TABLAS DE SEGUIMIENTO Y VISITAS
-- ============================================================================

CREATE TABLE visitas_cliente (
    visita_id NUMBER PRIMARY KEY,
    cliente_id NUMBER NOT NULL REFERENCES clientes(cliente_id),
    usuario_id NUMBER NOT NULL REFERENCES usuarios(usuario_id),
    zona_id NUMBER NOT NULL REFERENCES zonas(zona_id),
    fecha_visita TIMESTAMP DEFAULT SYSTIMESTAMP,
    latitud NUMBER(10, 8),
    longitud NUMBER(11, 8),
    tipo_visita VARCHAR2(50) NOT NULL,
    notas VARCHAR2(500),
    resultado VARCHAR2(100),
    CHECK (tipo_visita IN ('VENTA', 'SEGUIMIENTO', 'SOPORTE', 'COBRANZA'))
);

CREATE INDEX idx_visitas_cliente ON visitas_cliente(cliente_id);
CREATE INDEX idx_visitas_usuario ON visitas_cliente(usuario_id);
CREATE INDEX idx_visitas_zona ON visitas_cliente(zona_id);
CREATE INDEX idx_visitas_fecha ON visitas_cliente(fecha_visita);

CREATE TABLE tracking_pedidos (
    tracking_id NUMBER PRIMARY KEY,
    pedido_id NUMBER NOT NULL REFERENCES pedidos(pedido_id),
    estado_anterior VARCHAR2(50),
    estado_nuevo VARCHAR2(50) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT SYSTIMESTAMP,
    usuario_id NUMBER REFERENCES usuarios(usuario_id),
    notas VARCHAR2(300)
);

CREATE INDEX idx_tracking_pedido ON tracking_pedidos(pedido_id);
CREATE INDEX idx_tracking_fecha ON tracking_pedidos(fecha_cambio);

-- ============================================================================
-- 9. TABLA DE REPORTERÍA Y DATA WAREHOUSE
-- ============================================================================

CREATE TABLE venta_diaria (
    venta_diaria_id NUMBER PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    zona_id NUMBER NOT NULL REFERENCES zonas(zona_id),
    categoria_id NUMBER NOT NULL REFERENCES categorias(categoria_id),
    cantidad_vendida NUMBER(10, 0) NOT NULL,
    monto_vendido NUMBER(12, 2) NOT NULL,
    cantidad_pedidos NUMBER(5, 0) NOT NULL,
    fecha_carga TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE UNIQUE INDEX idx_venta_diaria_unique ON venta_diaria(fecha_venta, zona_id, categoria_id);
CREATE INDEX idx_venta_diaria_zona ON venta_diaria(zona_id);
CREATE INDEX idx_venta_diaria_fecha ON venta_diaria(fecha_venta);

-- ============================================================================
-- 10. TRIGGERS - AUTOMATIZACIÓN
-- ============================================================================

-- Trigger para crear movimiento de inventario cuando se reserva stock
CREATE OR REPLACE TRIGGER trg_reserva_inventario
BEFORE INSERT ON detalles_pedido
FOR EACH ROW
DECLARE
    v_inventario_id NUMBER;
    v_zona_id NUMBER;
BEGIN
    -- Obtener zona del pedido
    SELECT zona_id INTO v_zona_id 
    FROM pedidos 
    WHERE pedido_id = :NEW.pedido_id;
    
    -- Obtener ID de inventario
    SELECT inventario_id INTO v_inventario_id 
    FROM inventario 
    WHERE producto_id = :NEW.producto_id AND zona_id = v_zona_id;
    
    -- Validar disponibilidad
    UPDATE inventario 
    SET cantidad_disponible = cantidad_disponible - :NEW.cantidad,
        cantidad_reservada = cantidad_reservada + :NEW.cantidad
    WHERE inventario_id = v_inventario_id;
    
    -- Registrar movimiento
    INSERT INTO movimientos_inventario (movimiento_id, inventario_id, tipo_movimiento, cantidad, usuario_id, motivo)
    VALUES (seq_inventario.NEXTVAL, v_inventario_id, 'RESERVA', :NEW.cantidad, 1, 'Reserva automática pedido ' || :NEW.pedido_id);
END;
/

-- Trigger para actualizar fecha de modificación en usuarios
CREATE OR REPLACE TRIGGER trg_actualizacion_usuarios
BEFORE UPDATE ON usuarios
FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- Trigger para actualizar fecha de modificación en clientes
CREATE OR REPLACE TRIGGER trg_actualizacion_clientes
BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- Trigger para actualizar fecha de modificación en productos
CREATE OR REPLACE TRIGGER trg_actualizacion_productos
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- Trigger para actualizar fecha de modificación en pedidos
CREATE OR REPLACE TRIGGER trg_actualizacion_pedidos
BEFORE UPDATE ON pedidos
FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- ============================================================================
-- 11. PAQUETES - PROCEDIMIENTOS Y FUNCIONES
-- ============================================================================

-- Paquete de Gestión de Pedidos
CREATE OR REPLACE PACKAGE pkg_pedidos AS
    PROCEDURE crear_pedido(
        p_cliente_id IN NUMBER,
        p_usuario_id IN NUMBER,
        p_zona_id IN NUMBER,
        p_notas IN VARCHAR2,
        p_pedido_id OUT NUMBER
    );
    
    PROCEDURE cancelar_pedido(
        p_pedido_id IN NUMBER,
        p_usuario_id IN NUMBER
    );
    
    PROCEDURE actualizar_estado_pedido(
        p_pedido_id IN NUMBER,
        p_nuevo_estado_id IN NUMBER,
        p_usuario_id IN NUMBER,
        p_notas IN VARCHAR2
    );
    
    FUNCTION calcular_total_pedido(
        p_pedido_id IN NUMBER
    ) RETURN NUMBER;
    
    FUNCTION obtener_top_10_productos RETURN SYS_REFCURSOR;
    
END pkg_pedidos;
/

-- Cuerpo del paquete de Pedidos
CREATE OR REPLACE PACKAGE BODY pkg_pedidos AS

    PROCEDURE crear_pedido(
        p_cliente_id IN NUMBER,
        p_usuario_id IN NUMBER,
        p_zona_id IN NUMBER,
        p_notas IN VARCHAR2,
        p_pedido_id OUT NUMBER
    ) IS
    BEGIN
        p_pedido_id := seq_pedido.NEXTVAL;
        
        INSERT INTO pedidos (
            pedido_id, cliente_id, usuario_id, estado_id, zona_id,
            numero_pedido, subtotal, impuesto, total, notas
        ) VALUES (
            p_pedido_id, p_cliente_id, p_usuario_id, 1, p_zona_id,
            'PED-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || p_pedido_id,
            0, 0, 0, p_notas
        );
        
        COMMIT;
    END crear_pedido;
    
    PROCEDURE cancelar_pedido(
        p_pedido_id IN NUMBER,
        p_usuario_id IN NUMBER
    ) IS
    BEGIN
        UPDATE pedidos 
        SET estado_id = 6 
        WHERE pedido_id = p_pedido_id;
        
        INSERT INTO tracking_pedidos (tracking_id, pedido_id, estado_nuevo, usuario_id, notas)
        VALUES (seq_inventario.NEXTVAL, p_pedido_id, 'CANCELADO', p_usuario_id, 'Cancelación manual');
        
        COMMIT;
    END cancelar_pedido;
    
    PROCEDURE actualizar_estado_pedido(
        p_pedido_id IN NUMBER,
        p_nuevo_estado_id IN NUMBER,
        p_usuario_id IN NUMBER,
        p_notas IN VARCHAR2
    ) IS
        v_estado_anterior NUMBER;
    BEGIN
        SELECT estado_id INTO v_estado_anterior FROM pedidos WHERE pedido_id = p_pedido_id;
        
        UPDATE pedidos 
        SET estado_id = p_nuevo_estado_id 
        WHERE pedido_id = p_pedido_id;
        
        INSERT INTO tracking_pedidos (tracking_id, pedido_id, estado_anterior, estado_nuevo, usuario_id, notas)
        SELECT seq_inventario.NEXTVAL, p_pedido_id, nombre_estado, 
               (SELECT nombre_estado FROM estado_pedido WHERE estado_id = p_nuevo_estado_id),
               p_usuario_id, p_notas
        FROM estado_pedido 
        WHERE estado_id = v_estado_anterior;
        
        COMMIT;
    END actualizar_estado_pedido;
    
    FUNCTION calcular_total_pedido(
        p_pedido_id IN NUMBER
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT SUM(total_linea) INTO v_total 
        FROM detalles_pedido 
        WHERE pedido_id = p_pedido_id;
        
        RETURN COALESCE(v_total, 0);
    END calcular_total_pedido;
    
    FUNCTION obtener_top_10_productos RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT p.producto_id, p.nombre_producto, p.precio_unitario, 
                   COUNT(dp.detalle_pedido_id) as cantidad_vendida,
                   SUM(dp.cantidad) as unidades_vendidas
            FROM productos p
            LEFT JOIN detalles_pedido dp ON p.producto_id = dp.producto_id
            WHERE p.activo = 'S'
            GROUP BY p.producto_id, p.nombre_producto, p.precio_unitario
            ORDER BY cantidad_vendida DESC
            FETCH FIRST 10 ROWS ONLY;
        
        RETURN v_cursor;
    END obtener_top_10_productos;
    
END pkg_pedidos;
/

-- Paquete de Gestión de Inventario
CREATE OR REPLACE PACKAGE pkg_inventario AS
    PROCEDURE ajustar_inventario(
        p_producto_id IN NUMBER,
        p_zona_id IN NUMBER,
        p_cantidad IN NUMBER,
        p_tipo_movimiento IN VARCHAR2,
        p_usuario_id IN NUMBER,
        p_motivo IN VARCHAR2
    );
    
    FUNCTION obtener_disponibilidad(
        p_producto_id IN NUMBER,
        p_zona_id IN NUMBER
    ) RETURN NUMBER;
    
    PROCEDURE alertar_stock_bajo;
    
END pkg_inventario;
/

CREATE OR REPLACE PACKAGE BODY pkg_inventario AS

    PROCEDURE ajustar_inventario(
        p_producto_id IN NUMBER,
        p_zona_id IN NUMBER,
        p_cantidad IN NUMBER,
        p_tipo_movimiento IN VARCHAR2,
        p_usuario_id IN NUMBER,
        p_motivo IN VARCHAR2
    ) IS
        v_inventario_id NUMBER;
    BEGIN
        SELECT inventario_id INTO v_inventario_id 
        FROM inventario 
        WHERE producto_id = p_producto_id AND zona_id = p_zona_id;
        
        IF p_tipo_movimiento = 'ENTRADA' THEN
            UPDATE inventario 
            SET cantidad_disponible = cantidad_disponible + p_cantidad,
                fecha_ultimo_ajuste = SYSTIMESTAMP
            WHERE inventario_id = v_inventario_id;
        ELSIF p_tipo_movimiento = 'SALIDA' THEN
            UPDATE inventario 
            SET cantidad_disponible = cantidad_disponible - p_cantidad,
                fecha_ultimo_ajuste = SYSTIMESTAMP
            WHERE inventario_id = v_inventario_id AND cantidad_disponible >= p_cantidad;
        END IF;
        
        INSERT INTO movimientos_inventario (
            movimiento_id, inventario_id, tipo_movimiento, 
            cantidad, usuario_id, motivo
        ) VALUES (
            seq_inventario.NEXTVAL, v_inventario_id, p_tipo_movimiento, 
            p_cantidad, p_usuario_id, p_motivo
        );
        
        COMMIT;
    END ajustar_inventario;
    
    FUNCTION obtener_disponibilidad(
        p_producto_id IN NUMBER,
        p_zona_id IN NUMBER
    ) RETURN NUMBER IS
        v_cantidad NUMBER;
    BEGIN
        SELECT cantidad_disponible INTO v_cantidad 
        FROM inventario 
        WHERE producto_id = p_producto_id AND zona_id = p_zona_id;
        
        RETURN COALESCE(v_cantidad, 0);
    END obtener_disponibilidad;
    
    PROCEDURE alertar_stock_bajo IS
    BEGIN
        INSERT INTO movimientos_inventario (
            movimiento_id, inventario_id, tipo_movimiento, 
            cantidad, usuario_id, motivo
        )
        SELECT seq_inventario.NEXTVAL, inventario_id, 'ALERTA', 
               cantidad_disponible, 1, 'Stock por debajo del mínimo'
        FROM inventario 
        WHERE cantidad_disponible < cantidad_minima AND cantidad_disponible > 0;
        
        COMMIT;
    END alertar_stock_bajo;
    
END pkg_inventario;
/

-- Paquete de Gestión Financiera
CREATE OR REPLACE PACKAGE pkg_financiero AS
    PROCEDURE generar_factura(
        p_pedido_id IN NUMBER,
        p_factura_id OUT NUMBER
    );
    
    PROCEDURE registrar_pago(
        p_cuenta_pagar_id IN NUMBER,
        p_monto IN NUMBER,
        p_forma_pago IN VARCHAR2,
        p_usuario_id IN NUMBER
    );
    
    FUNCTION obtener_cuentas_por_pagar(
        p_cliente_id IN NUMBER
    ) RETURN SYS_REFCURSOR;
    
    PROCEDURE actualizar_atrasos;
    
END pkg_financiero;
/

CREATE OR REPLACE PACKAGE BODY pkg_financiero AS

    PROCEDURE generar_factura(
        p_pedido_id IN NUMBER,
        p_factura_id OUT NUMBER
    ) IS
        v_cliente_id NUMBER;
        v_subtotal NUMBER;
        v_impuesto NUMBER;
        v_total NUMBER;
        v_fecha_vencimiento DATE;
    BEGIN
        p_factura_id := seq_factura.NEXTVAL;
        
        SELECT cliente_id INTO v_cliente_id FROM pedidos WHERE pedido_id = p_pedido_id;
        
        SELECT 
            SUM(total_linea), 
            SUM(total_linea) * 0.16
        INTO v_subtotal, v_impuesto
        FROM detalles_pedido 
        WHERE pedido_id = p_pedido_id;
        
        v_total := v_subtotal + v_impuesto;
        v_fecha_vencimiento := TRUNC(SYSDATE) + 30;
        
        INSERT INTO facturas (
            factura_id, pedido_id, cliente_id, numero_factura,
            subtotal, impuesto, total, fecha_vencimiento
        ) VALUES (
            p_factura_id, p_pedido_id, v_cliente_id,
            'FAC-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || p_factura_id,
            v_subtotal, v_impuesto, v_total, v_fecha_vencimiento
        );
        
        INSERT INTO cuentas_pagar (
            cuenta_pagar_id, factura_id, cliente_id,
            monto_original, monto_pendiente, fecha_vencimiento
        ) VALUES (
            seq_cuentas_pagar.NEXTVAL, p_factura_id, v_cliente_id,
            v_total, v_total, v_fecha_vencimiento
        );
        
        COMMIT;
    END generar_factura;
    
    PROCEDURE registrar_pago(
        p_cuenta_pagar_id IN NUMBER,
        p_monto IN NUMBER,
        p_forma_pago IN VARCHAR2,
        p_usuario_id IN NUMBER
    ) IS
        v_pago_id NUMBER;
    BEGIN
        UPDATE cuentas_pagar 
        SET monto_pagado = monto_pagado + p_monto,
            monto_pendiente = monto_pendiente - p_monto,
            estado_pago = CASE WHEN (monto_pendiente - p_monto) = 0 THEN 'PAGADA' ELSE 'PENDIENTE' END
        WHERE cuenta_pagar_id = p_cuenta_pagar_id;
        
        v_pago_id := seq_cuentas_pagar.NEXTVAL;
        
        INSERT INTO pagos (
            pago_id, cuenta_pagar_id, monto_pagado, 
            forma_pago, usuario_registro
        ) VALUES (
            v_pago_id, p_cuenta_pagar_id, p_monto, 
            p_forma_pago, p_usuario_id
        );
        
        COMMIT;
    END registrar_pago;
    
    FUNCTION obtener_cuentas_por_pagar(
        p_cliente_id IN NUMBER
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT cp.cuenta_pagar_id, f.numero_factura, cp.monto_original,
                   cp.monto_pagado, cp.monto_pendiente, cp.fecha_vencimiento,
                   cp.estado_pago, TRUNC(SYSDATE - cp.fecha_vencimiento) as dias_atraso
            FROM cuentas_pagar cp
            JOIN facturas f ON cp.factura_id = f.factura_id
            WHERE cp.cliente_id = p_cliente_id
            ORDER BY cp.fecha_vencimiento;
        
        RETURN v_cursor;
    END obtener_cuentas_por_pagar;
    
    PROCEDURE actualizar_atrasos IS
    BEGIN
        UPDATE cuentas_pagar 
        SET dias_atraso = TRUNC(SYSDATE - fecha_vencimiento),
            estado_pago = CASE 
                            WHEN TRUNC(SYSDATE) > fecha_vencimiento AND monto_pendiente > 0 THEN 'VENCIDA'
                            ELSE estado_pago
                          END
        WHERE monto_pendiente > 0;
        
        COMMIT;
    END actualizar_atrasos;
    
END pkg_financiero;
/

-- ============================================================================
-- 12. JOBS - PROCESOS AUTOMÁTICOS
-- ============================================================================

-- Job para alertar stock bajo (cada 6 horas)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'JOB_ALERTA_STOCK',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN pkg_inventario.alertar_stock_bajo(); END;',
        start_date => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY;INTERVAL=6',
        enabled => TRUE
    );
END;
/

-- Job para actualizar atrasos en cuentas por pagar (diariamente a las 2 AM)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'JOB_ACTUALIZAR_ATRASOS',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN pkg_financiero.actualizar_atrasos(); END;',
        start_date => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
        enabled => TRUE
    );
END;
/

-- ============================================================================
-- 13. VISTAS - CONSULTAS PREFORMATEADAS
-- ============================================================================

CREATE OR REPLACE VIEW v_pedidos_activos AS
SELECT 
    p.pedido_id,
    p.numero_pedido,
    c.razon_social,
    ep.nombre_estado,
    p.total,
    p.fecha_pedido,
    z.nombre_zona
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.cliente_id
JOIN estado_pedido ep ON p.estado_id = ep.estado_id
JOIN zonas z ON p.zona_id = z.zona_id
WHERE p.estado_id NOT IN (5, 6, 7)
ORDER BY p.fecha_pedido DESC;

CREATE OR REPLACE VIEW v_inventario_bajo_stock AS
SELECT 
    i.inventario_id,
    pr.nombre_producto,
    pr.producto_id,
    z.nombre_zona,
    i.cantidad_disponible,
    i.cantidad_minima
FROM inventario i
JOIN productos pr ON i.producto_id = pr.producto_id
JOIN zonas z ON i.zona_id = z.zona_id
WHERE i.cantidad_disponible <= i.cantidad_minima
ORDER BY i.cantidad_disponible ASC;

CREATE OR REPLACE VIEW v_ventas_por_zona AS
SELECT 
    z.zona_id,
    z.nombre_zona,
    COUNT(DISTINCT p.pedido_id) as cantidad_pedidos,
    SUM(p.total) as monto_total,
    AVG(p.total) as promedio_pedido
FROM zonas z
LEFT JOIN pedidos p ON z.zona_id = p.zona_id AND p.estado_id = 5
WHERE z.activo = 'S'
GROUP BY z.zona_id, z.nombre_zona
ORDER BY monto_total DESC;

CREATE OR REPLACE VIEW v_cuentas_vencidas AS
SELECT 
    cp.cuenta_pagar_id,
    c.razon_social,
    f.numero_factura,
    cp.monto_pendiente,
    cp.fecha_vencimiento,
    TRUNC(SYSDATE - cp.fecha_vencimiento) as dias_atraso
FROM cuentas_pagar cp
JOIN facturas f ON cp.factura_id = f.factura_id
JOIN clientes c ON cp.cliente_id = c.cliente_id
WHERE cp.estado_pago = 'VENCIDA'
ORDER BY cp.fecha_vencimiento ASC;

-- ============================================================================
-- 14. DATOS DE PRUEBA
-- ============================================================================

-- Insertar zonas
INSERT INTO zonas (zona_id, nombre_zona, codigo_region, latitud, longitud)
VALUES (seq_zona.NEXTVAL, 'Zona Centro', 'CDMX', 19.4326, -99.1332);

INSERT INTO zonas (zona_id, nombre_zona, codigo_region, latitud, longitud)
VALUES (seq_zona.NEXTVAL, 'Zona Norte', 'MTY', 25.6866, -100.3161);

INSERT INTO zonas (zona_id, nombre_zona, codigo_region, latitud, longitud)
VALUES (seq_zona.NEXTVAL, 'Zona Bajío', 'GTO', 20.8810, -101.6038);

-- Insertar usuario administrador
INSERT INTO usuarios (usuario_id, email, nombre_usuario, contraseña, nombre_completo, rol_id)
VALUES (seq_usuario.NEXTVAL, 'admin@nexum.com', 'admin', 'admin123', 'Administrador Sistema', 1);

-- Insertar cliente de prueba
INSERT INTO usuarios (usuario_id, email, nombre_usuario, contraseña, nombre_completo, rol_id)
VALUES (seq_usuario.NEXTVAL, 'cliente1@empresa.com', 'cliente1', 'pass123', 'Juan Pérez', 3);

-- Insertar cliente en la tabla clientes
INSERT INTO clientes (cliente_id, usuario_id, zona_id, razon_social, rfc, direccion, ciudad, 
                      limite_credito, credito_disponible)
VALUES (1, 2, 1, 'Empresa Ejemplo S.A.', 'EMP123456789', 'Calle Principal 123', 'México', 50000, 50000);

-- Insertar productos de prueba
INSERT INTO productos (producto_id, categoria_id, nombre_producto, marca, modelo, precio_unitario, costo_unitario)
VALUES (seq_producto.NEXTVAL, 1, 'Laptop Dell XPS 15', 'Dell', 'XPS-15', 35000, 28000);

INSERT INTO productos (producto_id, categoria_id, nombre_producto, marca, modelo, precio_unitario, costo_unitario)
VALUES (seq_producto.NEXTVAL, 3, 'Switch Cisco Catalyst 2960', 'Cisco', 'C2960X-48TS', 18000, 14000);

INSERT INTO productos (producto_id, categoria_id, nombre_producto, marca, modelo, precio_unitario, costo_unitario)
VALUES (seq_producto.NEXTVAL, 5, 'SSD Samsung 970 EVO 1TB', 'Samsung', '970EVO', 2500, 1800);

-- Insertar inventario inicial
INSERT INTO inventario (inventario_id, producto_id, zona_id, cantidad_disponible, cantidad_reservada, cantidad_minima)
VALUES (seq_inventario.NEXTVAL, 1, 1, 15, 0, 5);

INSERT INTO inventario (inventario_id, producto_id, zona_id, cantidad_disponible, cantidad_reservada, cantidad_minima)
VALUES (seq_inventario.NEXTVAL, 2, 1, 8, 0, 3);

INSERT INTO inventario (inventario_id, producto_id, zona_id, cantidad_disponible, cantidad_reservada, cantidad_minima)
VALUES (seq_inventario.NEXTVAL, 3, 1, 45, 0, 10);

-- Insertar visita de prueba
INSERT INTO visitas_cliente (visita_id, cliente_id, usuario_id, zona_id, tipo_visita, resultado)
VALUES (seq_visita_cliente.NEXTVAL, 1, 1, 1, 'VENTA', 'Exitosa');

COMMIT;

-- ============================================================================
-- 15. COMPROBACIÓN FINAL
-- ============================================================================

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM usuarios;
    DBMS_OUTPUT.PUT_LINE('Total de usuarios: ' || v_count);
    
    SELECT COUNT(*) INTO v_count FROM productos;
    DBMS_OUTPUT.PUT_LINE('Total de productos: ' || v_count);
    
    SELECT COUNT(*) INTO v_count FROM inventario;
    DBMS_OUTPUT.PUT_LINE('Total de registros de inventario: ' || v_count);
    
    SELECT COUNT(*) INTO v_count FROM zonas;
    DBMS_OUTPUT.PUT_LINE('Total de zonas: ' || v_count);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Base de datos NEXUM creada exitosamente');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- ============================================================================
-- FINAL
-- ============================================================================
