DELETE FROM [dbo].[CompanyCategory] where [CompanyID] = @CompanyID;
DELETE FROM [dbo].[CompanyPriceHistory] where [CompanyID] = @CompanyID;
DELETE FROM [dbo].[dm_month_period_history] where [CompanyID] = @CompanyID;
DELETE FROM [dbo].[dm_year_period_history] where [CompanyID] = @CompanyID;
DELETE FROM [dbo].[Company] where [CompanyID] = @CompanyID;


