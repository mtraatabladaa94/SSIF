-- ================================================
USE [dbFacturacion-08-Junio-2016]
GO
/****** Object:  StoredProcedure [dbo].[SpProductosComprados]    Script Date: 01/28/2017 09:04:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MICHEL ROBERTO TRA�A TABLADA
-- Create date: 12/07/2016
-- Description:	ESTE PROCEDIMIENTO ALMACENADO PERMITE SELECCIONAR EL LISTADO DE PRODUCTOS VENDIDOS EN UN RANGO DE TIEMPO
-- =============================================
ALTER PROCEDURE [dbo].[SpProductosComprados]
	-- Add the parameters for the stored procedure here
@Inicio AS DATETIME,
@Final AS DATETIME,
@IDBodega AS VARCHAR(36),
@IDSerie AS VARCHAR(36),
@NEmpleado AS VARCHAR(50),
@Empleado AS VARCHAR(100),
@NProveedor AS VARCHAR(50),
@Proveedor AS VARCHAR(100),
@TipoCOMPRA AS INTEGER,
@MonInv AS Bit,
@Taza AS DECIMAL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--DECLARAR VARIABLES DE TAZA DE CAMBIO
	DECLARE @TazaCordoba AS DECIMAL(18,4)
	DECLARE @TazaDolar AS DECIMAL(18,4)
	IF @MonInv = 1
		BEGIN
			SET @TazaCordoba = 1
			SET @TazaDolar = @Taza
		END
	ELSE
		BEGIN
			SET @TazaDolar = 1
			SET @TazaCordoba = @Taza
		END
	-- 1. SELECCIONAR TODOS LOS DATOS
	IF @TipoCOMPRA <> 1 AND @TipoCOMPRA <> 2
	BEGIN
		(SELECT 
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) / SUM(DETALLE_COMPRA.CANTIDAD) AS PrecioPromedio,
			SUM(DETALLE_COMPRA.CANTIDAD) AS Cantidad,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_D * @TazaDolar END) AS Descuento,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) AS SubTotal,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.IVA_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.IVA_DIN_TOTAL_D * @TazaDolar END) AS Iva,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.TOTAL_D * @TazaDolar END) AS Total
		FROM
			PRODUCTO
			INNER JOIN EXISTENCIA ON PRODUCTO.IDPRODUCTO = EXISTENCIA.IDPRODUCTO
			INNER JOIN DETALLE_COMPRA ON EXISTENCIA.IDEXISTENCIA = DETALLE_COMPRA.IDEXISTENCIA
			INNER JOIN COMPRA ON DETALLE_COMPRA.IDCOMPRA = COMPRA.IDCOMPRA
			INNER JOIN EMPLEADO ON COMPRA.IDEMPLEADO = EMPLEADO.IDEMPLEADO
			INNER JOIN PROVEEDOR ON COMPRA.IDPROVEEDOR = PROVEEDOR.IDPROVEEDOR
			INNER JOIN SERIE ON COMPRA.IDSERIE = SERIE.IDSERIE
			INNER JOIN BODEGA ON SERIE.IDBODEGA = BODEGA.IDBODEGA
		WHERE
			COMPRA.ANULADO = 'N'
			AND COMPRA.FECHACOMPRA >= @INICIO
			AND COMPRA.FECHACOMPRA <= @FINAL
			AND BODEGA.IDBODEGA LIKE (@IDBODEGA + '%')
			AND SERIE.IDSERIE LIKE (@IDSERIE + '%')
			AND EMPLEADO.N_TRABAJADOR LIKE (@NEmpleado + '%')
			AND (EMPLEADO.NOMBRES + ' ' + EMPLEADO.APELLIDOS) LIKE (@Empleado + '%')
			AND PROVEEDOR.N_PROVEEDOR LIKE (@NProveedor + '%')
			AND (PROVEEDOR.NOMBRES + ' ' + PROVEEDOR.APELLIDOS) LIKE (@Proveedor + '%')
		GROUP BY
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION
		HAVING
			SUM(DETALLE_COMPRA.CANTIDAD) > 0
		)
	UNION
		(SELECT 
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) / SUM(DETALLE_COMPRA.CANTIDAD) AS PrecioPromedio,
			SUM(DETALLE_COMPRA.CANTIDAD) AS Cantidad,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_D * @TazaDolar END) AS Descuento,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) AS SubTotal,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.IVA_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.IVA_DIN_TOTAL_D * @TazaDolar END) AS Iva,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.TOTAL_D * @TazaDolar END) AS Total
		FROM
			PRODUCTO
			INNER JOIN EXISTENCIA ON PRODUCTO.IDPRODUCTO = EXISTENCIA.IDPRODUCTO
			INNER JOIN DETALLE_COMPRA ON EXISTENCIA.IDEXISTENCIA = DETALLE_COMPRA.IDEXISTENCIA
			INNER JOIN COMPRA ON DETALLE_COMPRA.IDCOMPRA = COMPRA.IDCOMPRA
			INNER JOIN EMPLEADO ON COMPRA.IDEMPLEADO = EMPLEADO.IDEMPLEADO
			INNER JOIN SERIE ON COMPRA.IDSERIE = SERIE.IDSERIE
			INNER JOIN BODEGA ON SERIE.IDBODEGA = BODEGA.IDBODEGA
		WHERE
			COMPRA.ANULADO = 'N'
			AND COMPRA.IDPROVEEDOR IS NULL
			AND COMPRA.FECHACOMPRA >= @INICIO
			AND COMPRA.FECHACOMPRA <= @FINAL
			AND BODEGA.IDBODEGA LIKE (@IDBODEGA + '%')
			AND SERIE.IDSERIE LIKE (@IDSERIE + '%')
			AND EMPLEADO.N_TRABAJADOR LIKE (@NEmpleado + '%')
			AND (EMPLEADO.NOMBRES + ' ' + EMPLEADO.APELLIDOS) LIKE (@Empleado + '%')
			AND RTRIM(@NProveedor) = ('')
			AND (COMPRA.PROVEEDORCONTADO) LIKE (@Proveedor + '%')
		GROUP BY
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION
		HAVING
			SUM(DETALLE_COMPRA.CANTIDAD) > 0
		)
	END






	--2. SELECCIONAR COMPRAS DE CONTADO
	IF @TipoCOMPRA = 1
	BEGIN
		(SELECT 
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) / SUM(DETALLE_COMPRA.CANTIDAD) AS PrecioPromedio,
			SUM(DETALLE_COMPRA.CANTIDAD) AS Cantidad,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_D * @TazaDolar END) AS Descuento,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) AS SubTotal,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.IVA_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.IVA_DIN_TOTAL_D * @TazaDolar END) AS Iva,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.TOTAL_D * @TazaDolar END) AS Total
		FROM
			PRODUCTO
			INNER JOIN EXISTENCIA ON PRODUCTO.IDPRODUCTO = EXISTENCIA.IDPRODUCTO
			INNER JOIN DETALLE_COMPRA ON EXISTENCIA.IDEXISTENCIA = DETALLE_COMPRA.IDEXISTENCIA
			INNER JOIN COMPRA ON DETALLE_COMPRA.IDCOMPRA = COMPRA.IDCOMPRA
			INNER JOIN EMPLEADO ON COMPRA.IDEMPLEADO = EMPLEADO.IDEMPLEADO
			INNER JOIN PROVEEDOR ON COMPRA.IDPROVEEDOR = PROVEEDOR.IDPROVEEDOR
			INNER JOIN SERIE ON COMPRA.IDSERIE = SERIE.IDSERIE
			INNER JOIN BODEGA ON SERIE.IDBODEGA = BODEGA.IDBODEGA
		WHERE
			COMPRA.ANULADO = 'N'
			AND COMPRA.FECHACOMPRA >= @INICIO
			AND COMPRA.FECHACOMPRA <= @FINAL
			AND BODEGA.IDBODEGA LIKE (@IDBODEGA + '%')
			AND SERIE.IDSERIE LIKE (@IDSERIE + '%')
			AND EMPLEADO.N_TRABAJADOR LIKE (@NEmpleado + '%')
			AND (EMPLEADO.NOMBRES + ' ' + EMPLEADO.APELLIDOS) LIKE (@Empleado + '%')
			AND PROVEEDOR.N_PROVEEDOR LIKE (@NProveedor + '%')
			AND (PROVEEDOR.NOMBRES + ' ' + PROVEEDOR.APELLIDOS) LIKE (@Proveedor + '%')
			AND COMPRA.CREDITO = 0
		GROUP BY
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION
		HAVING
			SUM(DETALLE_COMPRA.CANTIDAD) > 0
		)
	UNION
		(SELECT 
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) / SUM(DETALLE_COMPRA.CANTIDAD) AS PrecioPromedio,
			SUM(DETALLE_COMPRA.CANTIDAD) AS Cantidad,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_D * @TazaDolar END) AS Descuento,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) AS SubTotal,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.IVA_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.IVA_DIN_TOTAL_D * @TazaDolar END) AS Iva,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.TOTAL_D * @TazaDolar END) AS Total
		FROM
			PRODUCTO
			INNER JOIN EXISTENCIA ON PRODUCTO.IDPRODUCTO = EXISTENCIA.IDPRODUCTO
			INNER JOIN DETALLE_COMPRA ON EXISTENCIA.IDEXISTENCIA = DETALLE_COMPRA.IDEXISTENCIA
			INNER JOIN COMPRA ON DETALLE_COMPRA.IDCOMPRA = COMPRA.IDCOMPRA
			INNER JOIN EMPLEADO ON COMPRA.IDEMPLEADO = EMPLEADO.IDEMPLEADO
			INNER JOIN SERIE ON COMPRA.IDSERIE = SERIE.IDSERIE
			INNER JOIN BODEGA ON SERIE.IDBODEGA = BODEGA.IDBODEGA
		WHERE
			COMPRA.ANULADO = 'N'
			AND COMPRA.IDPROVEEDOR IS NULL
			AND COMPRA.FECHACOMPRA >= @INICIO
			AND COMPRA.FECHACOMPRA <= @FINAL
			AND BODEGA.IDBODEGA LIKE (@IDBODEGA + '%')
			AND SERIE.IDSERIE LIKE (@IDSERIE + '%')
			AND EMPLEADO.N_TRABAJADOR LIKE (@NEmpleado + '%')
			AND (EMPLEADO.NOMBRES + ' ' + EMPLEADO.APELLIDOS) LIKE (@Empleado + '%')
			AND RTRIM(@NProveedor) = ('')
			AND (COMPRA.PROVEEDORCONTADO) LIKE (@Proveedor + '%')
			AND COMPRA.CREDITO = 0
		GROUP BY
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION
		HAVING
			SUM(DETALLE_COMPRA.CANTIDAD) > 0
		)
	END






	--3. SELECCIONAR COMPRAS DE CREDITO
	IF @TipoCOMPRA = 2
	BEGIN
		(SELECT 
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) / SUM(DETALLE_COMPRA.CANTIDAD) AS PrecioPromedio,
			SUM(DETALLE_COMPRA.CANTIDAD) AS Cantidad,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.DESCUENTO_DIN_TOTAL_D * @TazaDolar END) AS Descuento,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.SUBTOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.SUBTOTAL_D * @TazaDolar END) AS SubTotal,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.IVA_DIN_TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.IVA_DIN_TOTAL_D * @TazaDolar END) AS Iva,
			SUM(CASE COMPRA.MONEDA WHEN 'C' THEN DETALLE_COMPRA.TOTAL_C / @TazaCordoba ELSE DETALLE_COMPRA.TOTAL_D * @TazaDolar END) AS Total
		FROM
			PRODUCTO
			INNER JOIN EXISTENCIA ON PRODUCTO.IDPRODUCTO = EXISTENCIA.IDPRODUCTO
			INNER JOIN DETALLE_COMPRA ON EXISTENCIA.IDEXISTENCIA = DETALLE_COMPRA.IDEXISTENCIA
			INNER JOIN COMPRA ON DETALLE_COMPRA.IDCOMPRA = COMPRA.IDCOMPRA
			INNER JOIN EMPLEADO ON COMPRA.IDEMPLEADO = EMPLEADO.IDEMPLEADO
			INNER JOIN PROVEEDOR ON COMPRA.IDPROVEEDOR = PROVEEDOR.IDPROVEEDOR
			INNER JOIN SERIE ON COMPRA.IDSERIE = SERIE.IDSERIE
			INNER JOIN BODEGA ON SERIE.IDBODEGA = BODEGA.IDBODEGA
		WHERE
			COMPRA.ANULADO = 'N'
			AND COMPRA.FECHACOMPRA >= @INICIO
			AND COMPRA.FECHACOMPRA <= @FINAL
			AND BODEGA.IDBODEGA LIKE (@IDBODEGA + '%')
			AND SERIE.IDSERIE LIKE (@IDSERIE + '%')
			AND EMPLEADO.N_TRABAJADOR LIKE (@NEmpleado + '%')
			AND (EMPLEADO.NOMBRES + ' ' + EMPLEADO.APELLIDOS) LIKE (@Empleado + '%')
			AND PROVEEDOR.N_PROVEEDOR LIKE (@NProveedor + '%')
			AND (PROVEEDOR.NOMBRES + ' ' + PROVEEDOR.APELLIDOS) LIKE (@Proveedor + '%')
			AND COMPRA.CREDITO = 1
		GROUP BY
			PRODUCTO.IDALTERNO,
			PRODUCTO.DESCRIPCION
		HAVING
			SUM(DETALLE_COMPRA.CANTIDAD) > 0
		)
	END
	--FIN DEL STATEMENT


END
