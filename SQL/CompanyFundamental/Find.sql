declare @CompanyID int;
set @CompanyID = 3
--{{PARAMS}}

select cf.*,c.*
,(SELECT SUBSTRING((
select ', ' + cat.CategoryName
from CompanyCategory cc
join Category cat on cc.CategoryID = cat.CategoryID
where cc.CompanyID = c.CompanyID
FOR XML PATH('')
),3,200000)) as Categories
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
from Company c
left outer join CompanyFundamental cf on c.CompanyID = cf.CompanyID 
where c.CompanyID = @CompanyID