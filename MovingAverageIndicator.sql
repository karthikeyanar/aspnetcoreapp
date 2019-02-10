declare @lastdate date;
set @lastdate = '2019-01-19';

select * from (
select *
,(case when isnull(isactive,0) = 1 then DATEDIFF(day, LastNotActiveDate, [Date]) else DATEDIFF(day, LastActiveDate, [Date]) end) as [Days] 
,(case when isnull(isactive,0) = 1 then case when isnull(LastNotActivePrice,0) > 0 then ((isnull([Close],0) - isnull(LastNotActivePrice,0)) / isnull(LastNotActivePrice,0)) * 100 else 0 end else case when isnull(LastActivePrice,0) > 0 then ((isnull([Close],0) - isnull(LastActivePrice,0)) / isnull(LastActivePrice,0)) * 100 else 0 end end) as Change
from (
select c.CompanyID,c.CompanyName,C.Symbol
,(select top 1 (case when isnull(cph.[Close],0) > isnull(cph.MA200,0) then 1 else 0 end) from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate order by cph.[Date] desc) as IsActive
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate  order by cph.[Date] desc) as [Close]
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate  order by cph.[Date] desc) as [Date]
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate  and (case when isnull(cph.[Close],0) > isnull(cph.MA200,0) then 1 else 0 end) = 0 order by cph.[Date] desc) as LastNotActiveDate
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate  and (case when isnull(cph.[Close],0) > isnull(cph.MA200,0) then 1 else 0 end) = 0 order by cph.[Date] desc) as LastNotActivePrice
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate  and (case when isnull(cph.[Close],0) > isnull(cph.MA200,0) then 1 else 0 end) = 1 order by cph.[Date] desc) as LastActiveDate
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] <= @lastdate  and (case when isnull(cph.[Close],0) > isnull(cph.MA200,0) then 1 else 0 end) = 1 order by cph.[Date] desc) as LastActivePrice
--,* 
from Company c
--where c.CompanyID = 3
) as tbl 
) as tbl2 where IsActive = 1 order by [Days] asc
go