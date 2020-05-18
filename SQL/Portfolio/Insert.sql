INSERT INTO [dbo].[PortfolioTransaction]
    ([CompanyID]
    ,[TransactionTypeID]
    ,[TransactionDate]
    ,[Quantity]
    ,[CostPerShare])
VALUES
    (@CompanyID
    ,@TransactionTypeID
    ,@TransactionDate
    ,@Quantity
    ,@CostPerShare)



