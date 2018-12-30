declare @count int;
select @count = isnull(count(*),0) from [CompanyShareHolding] where CompanyID = @CompanyID and ShareHoldingTypeID = @ShareHoldingTypeID;

IF @count = 0
	BEGIN
		INSERT INTO [dbo].[CompanyShareHolding]
           ([CompanyID]
           ,[ShareHoldingTypeID]
           ,[Total]
           ,[TotalShares])
		VALUES
           (@CompanyID
           ,@ShareHoldingTypeID
           ,@Total
           ,@TotalShares)
	END
ELSE
	BEGIN
		UPDATE [dbo].[CompanyShareHolding]
		   SET [Total] = @Total
			  ,[TotalShares] = @TotalShares
		 WHERE [CompanyID] = @CompanyID and ShareHoldingTypeID = @ShareHoldingTypeID; 
	END

update Company set LastMoneyControlDate = GETDATE() where CompanyID = @CompanyID