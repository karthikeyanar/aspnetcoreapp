DECLARE @PageSize INT = 10, @PageIndex INT = 1;
DECLARE @Name varchar(max);
DECLARE @LastTradingDate date;
DECLARE @CompanyID int;
DECLARE @LastFundamentalDate date;
DECLARE @LastMoneyControlDate date;
DECLARE @CompanyIDs varchar(max);
DECLARE @CategoryIDs varchar(max);
declare @isBookMarkCategory bit;-- = 1;
declare @isBookMark bit;-- = 1;
declare @fromDate datetime;
declare @toDate datetime;
declare @TempTable table(CompanyID int,YearPeriod int,CAGR decimal null)

--{{PARAMS}}

DECLARE @CompanyParamTable TABLE
(
ID int
)
DECLARE @CategoryParamTable TABLE
(
ID int
)
DECLARE @SQL varchar(max);

SELECT @SQL = 'SELECT ''' + REPLACE (@CompanyIDs,',',''' UNION SELECT ''') + ''''
INSERT INTO @CompanyParamTable (ID) EXEC (@SQL)

SELECT @SQL = 'SELECT ''' + REPLACE (@CategoryIDs,',',''' UNION SELECT ''') + ''''
INSERT INTO @CategoryParamTable (ID) EXEC (@SQL)
 
--select * from @CompanyParamTable 
declare @TempCategoryTable table(CompanyID int)
if isnull(@CategoryIDs,'') != ''
	begin
		insert into @TempCategoryTable(CompanyID)
		select cc.CompanyID from companycategory cc
		join category cat on cat.categoryid = cc.categoryid
		join @CategoryParamTable cpt on cpt.ID = cat.CategoryID 
		group by cc.CompanyID
	end 

insert into @TempTable(CompanyID,YearPeriod,CAGR)
select tbl3.CompanyID,10,CAGR from (
select tbl2.*
,((tbl2.CurrentPrice - tbl2.LastPrice)/tbl2.LastPrice)*100 as Growth 
,DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)  as DateDiff
,((POWER(cast(tbl2.CurrentPrice as float) / cast(tbl2.LastPrice as float),cast((cast(365 as float)/cast((DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)) as float)) as float))-1)*100) as CAGR
from (
select tbl.*
,(select top 1 cph.[Close] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-11, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-10, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPrice
,(select top 1 cph.[Date] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-11, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-10, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPriceDate
--,DATEADD(year, -10, tbl.LastDate) as LastDateYear  
from (
select c.CompanyID,c.CompanyName
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentPrice
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentDate
from Company c
--where c.CompanyName like 'God%'
) as tbl where tbl.CurrentDate is not null
) as tbl2 where tbl2.LastPrice > 0
) as tbl3 order by CAGR desc

--- 7 Years

insert into @TempTable(CompanyID,YearPeriod,CAGR)
select tbl3.CompanyID,7,CAGR from (
select tbl2.*
,((tbl2.CurrentPrice - tbl2.LastPrice)/tbl2.LastPrice)*100 as Growth 
,DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)  as DateDiff
,((POWER(cast(tbl2.CurrentPrice as float) / cast(tbl2.LastPrice as float),cast((cast(365 as float)/cast((DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)) as float)) as float))-1)*100) as CAGR
from (
select tbl.*
,(select top 1 cph.[Close] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-8, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-7, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPrice
,(select top 1 cph.[Date] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-8, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-7, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPriceDate
from (
select c.CompanyID,c.CompanyName
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentPrice
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentDate
from Company c
--where c.CompanyName like 'God%'
) as tbl where tbl.CurrentDate is not null
) as tbl2 where tbl2.LastPrice > 0
) as tbl3 order by CAGR desc

--- 5 Years

insert into @TempTable(CompanyID,YearPeriod,CAGR)
select tbl3.CompanyID,5,CAGR from (
select tbl2.*
,((tbl2.CurrentPrice - tbl2.LastPrice)/tbl2.LastPrice)*100 as Growth 
,DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)  as DateDiff
,((POWER(cast(tbl2.CurrentPrice as float) / cast(tbl2.LastPrice as float),cast((cast(365 as float)/cast((DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)) as float)) as float))-1)*100) as CAGR
from (
select tbl.*
,(select top 1 cph.[Close] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-6, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-5, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPrice
,(select top 1 cph.[Date] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-6, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-5, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPriceDate
--,DATEADD(year, -5, tbl.LastDate) as LastDateYear  
from (
select c.CompanyID,c.CompanyName
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentPrice
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentDate
from Company c
--where c.CompanyName like 'God%'
) as tbl where tbl.CurrentDate is not null
) as tbl2 where tbl2.LastPrice > 0
) as tbl3 order by CAGR desc

--- 3 Years

insert into @TempTable(CompanyID,YearPeriod,CAGR)
select tbl3.CompanyID,3,CAGR from (
select tbl2.*
,((tbl2.CurrentPrice - tbl2.LastPrice)/tbl2.LastPrice)*100 as Growth 
,DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)  as DateDiff
,((POWER(cast(tbl2.CurrentPrice as float) / cast(tbl2.LastPrice as float),cast((cast(365 as float)/cast((DATEDIFF(day,tbl2.LastPriceDate,tbl2.CurrentDate)) as float)) as float))-1)*100) as CAGR
from (
select tbl.*
,(select top 1 cph.[Close] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-4, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-3, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPrice
,(select top 1 cph.[Date] from CompanyPriceHistory cph 
where cph.CompanyID = tbl.CompanyID 
and cph.[Date] >= DATEADD(year,-4, tbl.CurrentDate)
and cph.[Date] <= DATEADD(year,-3, tbl.CurrentDate)
order by cph.[Date] desc)  as LastPriceDate
--,DATEADD(year, -3, tbl.LastDate) as LastDateYear  
from (
select c.CompanyID,c.CompanyName
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentPrice
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc)  as CurrentDate
from Company c
--where c.CompanyName like 'God%'
) as tbl where tbl.CurrentDate is not null
) as tbl2 where tbl2.LastPrice > 0
) as tbl3 order by CAGR desc

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)

if isnull(@isBookMarkCategory,0) = 1
	begin
		insert into @TempBookMarkTable(CompanyID,IsBookMark)
		select c.CompanyID,1 as BookMark from company c
		left outer join companycategory cc on cc.companyid = c.companyid
		left outer join category cat on cat.categoryid = cc.categoryid
		where cat.IsBookMark = 1
		group by c.CompanyID
	end

select tbl.*
, DATEDIFF(day,tbl.LastPriceDate,tbl.CurrentDate) as DateDiff2
,((POWER(cast(tbl.CurrentPrice as float) / cast(tbl.LastPrice as float),cast((cast(365 as float)/cast((DATEDIFF(day,tbl.LastPriceDate,tbl.CurrentDate)) as float)) as float))-1)*100) as CAGR from (
select c.CompanyID,c.Symbol,c.CompanyName
,STUFF((SELECT ', ' + cat.CategoryName
          FROM CompanyCategory cc
		  join Category cat on cat.CategoryID = cc.CategoryID
          WHERE cc.CompanyID = c.CompanyID 
		  and cat.CategoryName not like '%NIFTY%'
		  and cat.CategoryName not like '%LARGE%'
		  and cat.CategoryName not like '%SMALL%'
		  and cat.CategoryName not like '%MIDCAP%'
		  and cat.CategoryName not like '%CAN-SLIM%'
          FOR XML PATH('')), 1, 1, '') [Category] 
,t3.CAGR as Year_3
,t5.CAGR as Year_5
,t7.CAGR as Year_7
,t10.CAGR as Year_10
,cf.MarketCapital 
,c.IsBookMark
,(select top 1 cph.[Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] >= '2007-12-01' order by cph.[Date] asc) as LastPrice
,(select top 1 cph.[Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] >= '2007-12-01' order by cph.[Date] asc) as LastPriceDate
,(select top 1 cph.[Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc) as CurrentPrice
,(select top 1 cph.[Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID order by cph.[Date] desc) as CurrentDate
--,c.* 
from Company c 
left outer join @TempCategoryTable tc on tc.CompanyID = c.CompanyID
left outer join @TempBookMarkTable tb on tb.CompanyID = c.CompanyID 
left outer join CompanyFundamental cf on cf.CompanyID = c.CompanyID 
left outer join @TempTable t10 on t10.CompanyID = c.CompanyID and t10.YearPeriod = 10
left outer join @TempTable t7 on t7.CompanyID = c.CompanyID and t7.YearPeriod = 7
left outer join @TempTable t5 on t5.CompanyID = c.CompanyID and t5.YearPeriod = 5
left outer join @TempTable t3 on t3.CompanyID = c.CompanyID and t3.YearPeriod = 3
where (c.IsBookMark = @isBookMark or @isBookMark is null) 
and (tb.CompanyID > 0 or @isBookMarkCategory is null)
and (tc.CompanyID > 0 or @CategoryIDs is null)
--where t10.CAGR >= 15
--and t7.CAGR >= 15
--and t5.CAGR >= 15
--and t3.CAGR >= 15
) as tbl order by DateDiff2 desc,MarketCapital desc,CAGR desc
--order by cf.MarketCapital desc,t10.CAGR desc,t7.CAGR desc,t5.CAGR desc,t3.CAGR desc