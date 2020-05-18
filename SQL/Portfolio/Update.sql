UPDATE [dbo].[PortfolioTransaction]
   SET [CompanyID] = @CompanyID
      ,[TransactionTypeID] = @TransactionTypeID
      ,[TransactionDate] = @TransactionDate
      ,[Quantity] = @Quantity
      ,[CostPerShare] = @CostPerShare
 WHERE PortfolioTransactionID = @PortfolioTransactionID
