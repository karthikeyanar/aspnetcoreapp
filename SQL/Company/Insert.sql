INSERT INTO [dbo].[Company]
([CompanyName]
,[Symbol]
,[IsBookMark]
,[IsArchive]
,[InvestingUrl]
,[MoneyControlSymbol]
,[MoneyControlUrl]
)
VALUES
(@CompanyName
,@Symbol
,@IsBookMark
,@IsArchive
,@InvestingUrl
,@MoneyControlSymbol
,@MoneyControlUrl
)



