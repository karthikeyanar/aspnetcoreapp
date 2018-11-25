declare @isBookMarkCategory bit;
set @isBookMarkCategory = 0;

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)
insert into @TempBookMarkTable(CompanyID,IsBookMark)
select c.CompanyID,1 as BookMark from company c
left outer join companycategory cc on cc.companyid = c.companyid
left outer join category cat on cat.categoryid = cc.categoryid
where (cat.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null) 
group by c.CompanyID

select tbl.*
from (
select 
c.CompanyName
,c.Symbol
,c.InvestingUrl 
,(select AVG(Percentage) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID) as Average
,(select AVG(Percentage) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2016 and his.CompanyID = c.CompanyID) as Last3YearsAverage
,(select AVG(Percentage) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=YEAR(GETDATE()) and his.CompanyID = c.CompanyID) as CurrentYearPercentage
,(select count(*) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID and his.Percentage > 0) as Positive
,(select count(*) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID) as TotalYear
,cast((cast((select count(*) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID and his.Percentage > 0) as decimal(19,2)) / cast((select count(*) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID) as decimal(19,2))) as decimal(19,2)) Radio
,(select top 1 his.[close] from CompanyPriceHistory his where his.CompanyID = c.CompanyID order by his.[Date] desc) as CurrentPrice
,cf.Week52High
,case when cf.Week52High > 0 then ((((select top 1 his.[close] from CompanyPriceHistory his where his.CompanyID = c.CompanyID order by his.[Date] desc) - cf.Week52High) / cf.Week52High) * 100) else 0 end as Down
,cf.ROE
,cf.ROCE
,cf.EPS
,cf.StockPE 
,cf.DividendYield 
,cf.PiotroskiScore
from company c
join CompanyFundamental cf on c.CompanyID = cf.CompanyID 
join @TempBookMarkTable tb on tb.CompanyID = c.CompanyID 
) as tbl 
where tbl.Positive > 0 
and tbl.Average > 0
--and tbl.PiotroskiScore >= 7
order by 
Down asc
,TotalYear desc
,Radio desc
,Average desc
,Last3YearsAverage desc
go

