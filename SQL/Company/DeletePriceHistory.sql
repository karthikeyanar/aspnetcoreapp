DELETE FROM [dbo].[CompanyPriceHistory] where [CompanyID] = @CompanyID;
DELETE FROM [dbo].[dm_month_period_history] where [CompanyID] = @CompanyID;
DELETE FROM [dbo].[dm_year_period_history] where [CompanyID] = @CompanyID;
Update [dbo].Company set LastTradingDate = null where CompanyID = @CompanyID;