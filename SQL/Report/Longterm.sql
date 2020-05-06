DECLARE @PageSize INT = 2000, @PageIndex INT = 1;
DECLARE @IsBookMark bit;
--set @IsBookMark = 1;

--{{PARAMS}}

select count(*) as [Count] from (
select 
tbl.* 
,case when totalyears > 0 then cast(((cast(Positive as float) / cast(TotalYears as float))*100) as float) else 0 end as PositivePercentage
from (
select 
c.CompanyID 
,isnull(c.IsBookMark,0) as IsBookMark
,c.CompanyName
,c.Symbol 
,c.MoneyControlSymbol 
,(SELECT SUBSTRING((
select ', ' + cat.CategoryName
from CompanyCategory cc
join Category cat on cc.CategoryID = cat.CategoryID
where cc.CompanyID = c.CompanyID
FOR XML PATH('')
),3,200000)) as Categories
,cf.PEG
,(select sum(isnull(Total,0)) from CompanyShareHolding csh where csh.CompanyID = c.CompanyID) as TotalInvestors
,(select sum(isnull(Total,0)) from CompanyShareHolding csh where csh.CompanyID = c.CompanyID and csh.ShareHoldingTypeID = 1) as MutualFunds
,(select sum(isnull(Total,0)) from CompanyShareHolding csh where csh.CompanyID = c.CompanyID and csh.ShareHoldingTypeID = 8) as QualifiedForeignInvestors
,cf.PiotroskiScore
,cf.GFactor 
,cf.DividendYield
,cf.ROE_3_Years 
,cf.Week52High
,(select top 1 isnull([close],0) from companypricehistory where companyid = c.companyid order by [date] desc) as CurrentPrice
,(select AVG(isnull(dyph.Percentage,0)) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID) as AvgYearProfit
,(select count(*) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID and isnull(dyph.Percentage,0) > 0) as Positive
,(select count(*) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID and isnull(dyph.Percentage,0) < 0) as Negative
,(select count(*) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID) as TotalYears
,(select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2018
where dyph.CompanyID = c.CompanyID) as Profit_2018
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2017
where dyph.CompanyID = c.CompanyID),0) as Profit_2017
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2016
where dyph.CompanyID = c.CompanyID),0) as Profit_2016
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2015
where dyph.CompanyID = c.CompanyID),0) as Profit_2015
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2014
where dyph.CompanyID = c.CompanyID),0) as Profit_2014
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2013
where dyph.CompanyID = c.CompanyID),0) as Profit_2013
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2012
where dyph.CompanyID = c.CompanyID),0) as Profit_2012
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2011
where dyph.CompanyID = c.CompanyID),0) as Profit_2011
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2010
where dyph.CompanyID = c.CompanyID),0) as Profit_2010
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2009
where dyph.CompanyID = c.CompanyID),0) as Profit_2009
--,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
--join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2008
--where dyph.CompanyID = c.CompanyID),0) as Profit_2008
--,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
--join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2007
--where dyph.CompanyID = c.CompanyID),0) as Profit_2007
from Company c
join companyfundamental cf on cf.companyid = c.companyid
where (c.IsBookMark = @IsBookMark  or @IsBookMark is null)
) as tbl 
--where TotalYears > 0
) as tbl2 

select * from (
select 
tbl.* 
,case when totalyears > 0 then cast(((cast(Positive as float) / cast(TotalYears as float))*100) as float) else 0 end as PositivePercentage
from (
select 
c.CompanyID 
,isnull(c.IsBookMark,0) as IsBookMark
,c.CompanyName
,c.Symbol 
,c.MoneyControlSymbol 
,(SELECT SUBSTRING((
select ', ' + cat.CategoryName
from CompanyCategory cc
join Category cat on cc.CategoryID = cat.CategoryID
where cc.CompanyID = c.CompanyID
FOR XML PATH('')
),3,200000)) as Categories
,cf.PEG
,(select sum(isnull(Total,0)) from CompanyShareHolding csh where csh.CompanyID = c.CompanyID) as TotalInvestors
,(select sum(isnull(Total,0)) from CompanyShareHolding csh where csh.CompanyID = c.CompanyID and csh.ShareHoldingTypeID = 1) as MutualFunds
,(select sum(isnull(Total,0)) from CompanyShareHolding csh where csh.CompanyID = c.CompanyID and csh.ShareHoldingTypeID = 8) as QualifiedForeignInvestors
,cf.PiotroskiScore
,cf.GFactor 
,cf.DividendYield
,cf.ROE_3_Years 
,cf.Week52High
,(select top 1 isnull([close],0) from companypricehistory where companyid = c.companyid order by [date] desc) as CurrentPrice
,(select AVG(isnull(dyph.Percentage,0)) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID) as AvgYearProfit
,(select count(*) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID and isnull(dyph.Percentage,0) > 0) as Positive
,(select count(*) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID and isnull(dyph.Percentage,0) < 0) as Negative
,(select count(*) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year > 2008
where dyph.CompanyID = c.CompanyID) as TotalYears
,(select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2019
where dyph.CompanyID = c.CompanyID) as Profit_2019
,(select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2018
where dyph.CompanyID = c.CompanyID) as Profit_2018
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2017
where dyph.CompanyID = c.CompanyID),0) as Profit_2017
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2016
where dyph.CompanyID = c.CompanyID),0) as Profit_2016
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2015
where dyph.CompanyID = c.CompanyID),0) as Profit_2015
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2014
where dyph.CompanyID = c.CompanyID),0) as Profit_2014
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2013
where dyph.CompanyID = c.CompanyID),0) as Profit_2013
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2012
where dyph.CompanyID = c.CompanyID),0) as Profit_2012
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2011
where dyph.CompanyID = c.CompanyID),0) as Profit_2011
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2010
where dyph.CompanyID = c.CompanyID),0) as Profit_2010
,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2009
where dyph.CompanyID = c.CompanyID),0) as Profit_2009
--,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
--join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2008
--where dyph.CompanyID = c.CompanyID),0) as Profit_2008
--,isnull((select isnull(dyph.Percentage,0) from dm_year_period_history dyph
--join dm_year_period yp on yp.dm_year_period_id = dyph.dm_year_period_id and yp.Year = 2007
--where dyph.CompanyID = c.CompanyID),0) as Profit_2007
from Company c
join companyfundamental cf on cf.companyid = c.companyid
where (c.IsBookMark = @IsBookMark  or @IsBookMark is null)
) as tbl 
--where TotalYears > 0
) as tbl2 
--where PositivePercentage >= 70 
--and PiotroskiScore >= 7
order by 
PositivePercentage desc,
TotalInvestors desc,
MutualFunds desc,
QualifiedForeignInvestors desc,
PiotroskiScore desc
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
