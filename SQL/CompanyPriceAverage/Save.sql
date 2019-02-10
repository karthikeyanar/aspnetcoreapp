declare @count int;
select @count = isnull(count(*),0) from [CompanyPriceAverage] where CompanyID = @CompanyID;

IF @count = 0
	BEGIN
      INSERT INTO [dbo].[CompanyPriceAverage]
           ([CompanyID]
           ,[CurrentPrice]
           ,[MA5]
           ,[MA10]
           ,[MA20]
           ,[MA50]
           ,[MA100]
           ,[MA200]
           ,[IsBuy_MA5]
           ,[IsBuy_MA10]
           ,[IsBuy_MA20]
           ,[IsBuy_MA50]
           ,[IsBuy_MA100]
           ,[IsBuy_MA200]
           ,[LastUpdatedDate]
           )
     VALUES
           (@CompanyID
           ,@CurrentPrice
           ,@MA5
           ,@MA10
           ,@MA20
           ,@MA50
           ,@MA100
           ,@MA200
           ,@IsBuy_MA5
           ,@IsBuy_MA10
           ,@IsBuy_MA20
           ,@IsBuy_MA50
           ,@IsBuy_MA100
           ,@IsBuy_MA200
           ,GetDate()
           )
	END
ELSE
	BEGIN
		UPDATE [dbo].[CompanyPriceAverage]
		   SET [CompanyID] = @CompanyID
            ,[CurrentPrice] = @CurrentPrice
            ,[MA5] = @MA5
            ,[MA10] = @MA10
            ,[MA20] = @MA20
            ,[MA50] = @MA50
            ,[MA100] = @MA100
            ,[MA200] = @MA200
            ,[IsBuy_MA5] = @IsBuy_MA5
            ,[IsBuy_MA10] = @IsBuy_MA10
            ,[IsBuy_MA20] = @IsBuy_MA20
            ,[IsBuy_MA50] = @IsBuy_MA50
            ,[IsBuy_MA100] = @IsBuy_MA100
            ,[IsBuy_MA200] = @IsBuy_MA200
            ,[LastUpdatedDate] = GetDate()
		 WHERE [CompanyID] = @CompanyID
	END
