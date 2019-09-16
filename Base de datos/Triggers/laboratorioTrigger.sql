﻿CREATE OR ALTER TRIGGER dbo.[LaboratorioTrigger] ON SadaraDb.dbo.[Laboratorio]
	AFTER INSERT, UPDATE, DELETE
AS

	DECLARE @triggerTransactionType AS VARCHAR(10);

	IF EXISTS(SELECT 1 FROM inserted) BEGIN
		IF NOT EXISTS(SELECT 1 FROM deleted) BEGIN
			SET @triggerTransactionType = 'INSERT';
		END
		ELSE BEGIN
			SET @triggerTransactionType = 'UPDATE';
		END
	END
	ELSE BEGIN
		SET @triggerTransactionType = 'DELETE';
	END

	DECLARE @countRegs INT;
	SET @countRegs = (SELECT COUNT(*) AS countRegs FROM inserted);

	DECLARE @countRegsDeleted INT;
	SET @countRegsDeleted = (SELECT COUNT(*) AS countRegs FROM deleted);

	DECLARE @laboratorioId VARCHAR(36);

	IF (@countRegs = 1 OR @countRegsDeleted = 1) BEGIN

		IF @countRegs = 1 BEGIN

			SELECT TOP 1 @laboratorioId = IDLABORATORIO FROM inserted;
			EXEC [dbo].SpInsertDataForSync
				@tableName = 'Laboratorio',
				@transactionType = @triggerTransactionType,
				@valueId = @laboratorioId;

		END
		ELSE BEGIN
			
			SELECT TOP 1 @laboratorioId = IDLABORATORIO FROM deleted;
			EXEC [dbo].SpInsertDataForSync
				@tableName = 'Laboratorio',
				@transactionType = @triggerTransactionType,
				@valueId = @laboratorioId;

		END
		
	END
	ELSE BEGIN
		
		IF(@countRegs = 1) BEGIN
			
			DECLARE laboratorioCursor CURSOR FOR
				SELECT IDLABORATORIO FROM inserted;

		END
		ELSE BEGIN

			DECLARE laboratorioCursor CURSOR FOR
				SELECT IDLABORATORIO FROM deleted;

		END

		OPEN laboratorioCursor;

		FETCH NEXT FROM laboratorioCursor INTO
			@laboratorioId;

		WHILE @@FETCH_STATUS = 0 BEGIN
			
			EXEC [dbo].SpInsertDataForSync
				@tableName = 'Laboratorio',
				@transactionType = @triggerTransactionType,
				@valueId = @laboratorioId;

			FETCH NEXT FROM laboratorioCursor INTO
				@laboratorioId;

		END

		CLOSE cotizacionDetalleCursor;
		DEALLOCATE cotizacionDetalleCursor;

	END
	
GO