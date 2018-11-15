UPDATE [dbo].[Company]
   SET [CompanyName] = @CompanyName
      ,[Symbol] = @Symbol
      ,[IsBookMark] = @IsBookMark
      ,[IsArchive] = @IsArchive
      ,[InvestingUrl] = @InvestingUrl
 WHERE [CompanyID] = @CompanyID


