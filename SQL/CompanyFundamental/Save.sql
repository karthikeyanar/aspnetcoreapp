declare @count int;
select @count = isnull(count(*),0) from [CompanyFundamental] where CompanyID = @CompanyID;

IF @count = 0
	BEGIN
		INSERT INTO [dbo].[CompanyFundamental]
				   ([CompanyID]
				   ,[ROE]
				   ,[ROE_3_Years]
				   ,[ROCE]
				   ,[ROCE_3_Years]
				   ,[StockPE]
				   ,[DividendYield]
				   ,[SalesGrowth]
				   ,[SalesGrowth_3_Years]
				   ,[SalesGrowth_5_Years]
				   ,[SalesGrowth_7_Years]
				   ,[SalesGrowth_10_Years]
				   ,[ProfitGrowth]
				   ,[ProfitGrowth_3_Years]
				   ,[ProfitGrowth_5_Years]
				   ,[ProfitGrowth_7_Years]
				   ,[ProfitGrowth_10_Years]
				   ,[DE]
				   ,[PEG]
				   ,[EPS]
				   ,[Interest]
				   ,[PromoterHolding]
				   ,[BookValue]
				   ,[FaceValue]
				   ,[CurrentPrice]
				   ,[MarketCapital]
				   ,[Week52High]
				   ,[Week52Low]
				   ,[PiotroskiScore]
				   ,[GFactor]
				   ,[PS]
				   ,[PB]
				   ,[LastUpdatedDate])
			 VALUES
				   (@CompanyID
				   ,@ROE
				   ,@ROE_3_Years
				   ,@ROCE
				   ,@ROCE_3_Years
				   ,@StockPE
				   ,@DividendYield
				   ,@SalesGrowth
				   ,@SalesGrowth_3_Years
				   ,@SalesGrowth_5_Years
				   ,@SalesGrowth_7_Years
				   ,@SalesGrowth_10_Years
				   ,@ProfitGrowth
				   ,@ProfitGrowth_3_Years
				   ,@ProfitGrowth_5_Years
				   ,@ProfitGrowth_7_Years
				   ,@ProfitGrowth_10_Years
				   ,@DE
				   ,@PEG
				   ,@EPS
				   ,@Interest
				   ,@PromoterHolding
				   ,@BookValue
				   ,@FaceValue
				   ,@CurrentPrice
				   ,@MarketCapital
				   ,@Week52High
				   ,@Week52Low
				   ,@PiotroskiScore
				   ,@GFactor
				   ,@PS
				   ,@PB
				   ,GETDATE())
	END
ELSE
	BEGIN
		UPDATE [dbo].[CompanyFundamental]
		   SET [ROE] = @ROE
			  ,[ROE_3_Years] = @ROE_3_Years
			  ,[ROCE] = @ROCE
			  ,[ROCE_3_Years] = @ROCE_3_Years
			  ,[StockPE] = @StockPE
			  ,[DividendYield] = @DividendYield
			  ,[SalesGrowth] = @SalesGrowth
			  ,[SalesGrowth_3_Years] = @SalesGrowth_3_Years
			  ,[SalesGrowth_5_Years] = @SalesGrowth_5_Years
			  ,[SalesGrowth_7_Years] = @SalesGrowth_7_Years
			  ,[SalesGrowth_10_Years] = @SalesGrowth_10_Years
			  ,[ProfitGrowth] = @ProfitGrowth
			  ,[ProfitGrowth_3_Years] = @ProfitGrowth_3_Years
			  ,[ProfitGrowth_5_Years] = @ProfitGrowth_5_Years
			  ,[ProfitGrowth_7_Years] = @ProfitGrowth_7_Years
			  ,[ProfitGrowth_10_Years] = @ProfitGrowth_10_Years
			  ,[DE] = @DE
			  ,[PEG] = @PEG
			  ,[EPS] = @EPS
			  ,[Interest] = @Interest
			  ,[PromoterHolding] = @PromoterHolding
			  ,[BookValue] = @BookValue
			  ,[FaceValue] = @FaceValue
			  ,[CurrentPrice] = @CurrentPrice
			  ,[MarketCapital] = @MarketCapital
			  ,[Week52High] = @Week52High
			  ,[Week52Low] = @Week52Low
			  ,[PiotroskiScore] = @PiotroskiScore
			  ,[GFactor] = @GFactor
			  ,[PS] = @PS
			  ,[PB] = @PB
			  ,[LastUpdatedDate] = GETDATE()
		 WHERE [CompanyID] = @CompanyID
	END
