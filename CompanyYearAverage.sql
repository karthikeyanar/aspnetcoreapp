select tbl.*
,(tbl.TotalYear - tbl.Positive) Diff
,(case when tbl.TotalYear > 0 then cast((cast(tbl.Positive as decimal(19,4)) / cast(tbl.TotalYear as decimal(19,4))) as decimal(19,4)) * 100 else 0 end) as Pe  from (
select 
c.CompanyID 
,c.CompanyName
,c.Symbol
,(select AVG(Percentage) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID) as Average
,(select count(*) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID and his.Percentage > 0) as Positive
,(select count(*) from dm_year_period_history his join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id where yp.[Year]>=2009 and his.CompanyID = c.CompanyID) as TotalYear
--,* 
from company c
) as tbl 
where tbl.Positive > 0
order by 
Positive desc
,(case when tbl.TotalYear > 0 then cast((cast(tbl.Positive as decimal(19,4)) / cast(tbl.TotalYear as decimal(19,4))) as decimal(19,4)) * 100 else 0 end) desc
,Average desc
go

