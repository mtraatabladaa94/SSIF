USE [SadaraDB]
GO
/****** Object:  StoredProcedure [dbo].[SpCrearExistenciaPorBodega]    Script Date: 03/30/2017 21:23:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SpCrearExistenciaPorBodega]
	-- Add the parameters for the stored procedure here
	@IDProducto AS CHAR(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO Existencia
	(
		IDEXISTENCIA,
		Reg,
		CANTIDAD,
		CONSIGNADO,
		IDBODEGA,
		IDPRODUCTO
	)
	SELECT
		NEWID(),
		GETDATE() AS Reg,
		0 AS CANTIDAD,
		0 AS CONSIGNADO,
		Bodega.IDBODEGA,
		@IDProducto AS IDPRODUCTO
	FROM
		Bodega
	INNER JOIN
		Existencia ON Bodega.IDBODEGA = Existencia.IDPRODUCTO
	WHERE
		Existencia.IDPRODUCTO <> @IDProducto
	
	
END
