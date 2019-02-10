declare @count int;
select @count = isnull(count(*),0) from [CompanyFundamental] where CompanyID = @CompanyID;

IF @count = 0
	BEGIN
		INSERT INTO [dbo].[CompanyFundamental]
           ([CompanyID]
           ,[ROCE]
           ,[StockPE]
           ,[DividendYield]
           ,[ROE]
           ,[ROE_3_Years]
           ,[ROE_5_Years]
           ,[ROE_7_Years]
           ,[ROE_10_Years]
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
           ,[EPS_Year_1]
           ,[EPS_Year_2]
           ,[EPS_Year_3]
           ,[EPS_Quater_1]
           ,[EPS_Quater_2]
           ,[NetProfit_Quater_1]
           ,[NetProfit_Quater_2]
           ,[NetProfit_Quater_3]
           ,[NetProfit_Quater_4]
           ,[NetProfit_Year_1]
           ,[NetProfit_Year_2]
           ,[NetProfit_Year_3]
           ,[DE]
           ,[PEG]
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
		   ,[QuaterProfits]
		   ,[YearProfits]
		   ,[QuaterSales]
		   ,[YearSales]
           ,[LastUpdatedDate])
		VALUES
           (@CompanyID
           ,@ROCE
           ,@StockPE
           ,@DividendYield
           ,@ROE
           ,@ROE_3_Years
           ,@ROE_5_Years
           ,@ROE_7_Years
           ,@ROE_10_Years
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
           ,@EPS_Year_1
           ,@EPS_Year_2
           ,@EPS_Year_3
           ,@EPS_Quater_1
           ,@EPS_Quater_2
           ,@NetProfit_Quater_1
           ,@NetProfit_Quater_2
           ,@NetProfit_Quater_3
           ,@NetProfit_Quater_4
           ,@NetProfit_Year_1
           ,@NetProfit_Year_2
           ,@NetProfit_Year_3
           ,@DE
           ,@PEG
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
		   ,@QuaterProfits
		   ,@YearProfits
		   ,@QuaterSales
		   ,@YearSales
           ,GETDATE())
	END
ELSE
	BEGIN
		UPDATE [dbo].[CompanyFundamental]
		   SET [CompanyID] = @CompanyID
			  ,[ROCE] = @ROCE
			  ,[StockPE] = @StockPE
			  ,[DividendYield] = @DividendYield
			  ,[ROE] = @ROE
			  ,[ROE_3_Years] = @ROE_3_Years
			  ,[ROE_5_Years] = @ROE_5_Years
			  ,[ROE_7_Years] = @ROE_7_Years
			  ,[ROE_10_Years] = @ROE_10_Years
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
			  ,[EPS_Year_1] = @EPS_Year_1
			  ,[EPS_Year_2] = @EPS_Year_2
			  ,[EPS_Year_3] = @EPS_Year_3
			  ,[EPS_Quater_1] = @EPS_Quater_1
			  ,[EPS_Quater_2] = @EPS_Quater_2
			  ,[NetProfit_Quater_1] = @NetProfit_Quater_1
			  ,[NetProfit_Quater_2] = @NetProfit_Quater_2
			  ,[NetProfit_Quater_3] = @NetProfit_Quater_3
			  ,[NetProfit_Quater_4] = @NetProfit_Quater_4
			  ,[NetProfit_Year_1] = @NetProfit_Year_1
			  ,[NetProfit_Year_2] = @NetProfit_Year_2
			  ,[NetProfit_Year_3] = @NetProfit_Year_3
			  ,[DE] = @DE
			  ,[PEG] = @PEG
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
			  ,[QuaterProfits] = @QuaterProfits
			  ,[YearProfits] = @YearProfits
			  ,[QuaterSales] = @QuaterSales
			  ,[YearSales] = @YearSales
			  ,[LastUpdatedDate] = GETDATE()
		 WHERE [CompanyID] = @CompanyID
	END
