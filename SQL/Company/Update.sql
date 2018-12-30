UPDATE [dbo].[Company]
   SET [CompanyName] = @CompanyName
      ,[Symbol] = @Symbol
      ,[IsBookMark] = @IsBookMark
      ,[IsArchive] = @IsArchive
      ,[InvestingUrl] = @InvestingUrl
	  ,[MoneyControlSymbol] = @MoneyControlSymbol
	  ,[MoneyControlUrl] = @MoneyControlUrl
 WHERE [CompanyID] = @CompanyID


