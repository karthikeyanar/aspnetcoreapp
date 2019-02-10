select * from (
select *
,(case when isnull(isactive,0) = 1 then DATEDIFF(day, LastNotActiveDate, [Date]) else DATEDIFF(day, LastActiveDate, [Date]) end) as [Days] 
,(case when isnull(isactive,0) = 1 then case when isnull(LastNotActivePrice,0) > 0 then ((isnull([Close],0) - isnull(LastNotActivePrice,0)) / isnull(LastNotActivePrice,0)) * 100 else 0 end else case when isnull(LastActivePrice,0) > 0 then ((isnull([Close],0) - isnull(LastActivePrice,0)) / isnull(LastActivePrice,0)) * 100 else 0 end end) as Change
from (
select c.CompanyID,c.CompanyName,c.Symbol
,c2h.IsActive
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] < c2h.[Date]  order by cph.[Date] desc) as [Close]
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] < c2h.[Date]  order by cph.[Date] desc) as [Date]
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] < c2h.[Date]  and cph.IsActive = 0 order by cph.[Date] desc) as LastNotActiveDate
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] < c2h.[Date]  and cph.IsActive = 0 order by cph.[Date] desc) as LastNotActivePrice
,(select top 1 [Date] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] < c2h.[Date]  and cph.IsActive = 1 order by cph.[Date] desc) as LastActiveDate
,(select top 1 [Close] from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID and cph.[Date] < c2h.[Date]  and cph.IsActive = 1 order by cph.[Date] desc) as LastActivePrice
from CompanyPriceHistory c2h
join Company c on c.CompanyID = c2h.CompanyID 
where c2h.CompanyID = 270
and c2h.IsActive = 1
--order by c2h.[Date] asc
) as tbl 
) as tbl2   order by [Date] asc,[Days] asc
go