select * from (
select c.CompanyID,c.CompanyName, c.Symbol, cph.[PrevClose] / cph.[Open] as SplitFactor
,cph.[Date],((cph.[Open] - cph.[PrevClose])/cph.[PrevClose]) * 100 as [Percentage] 
,cph.[Open]
,cph.[PrevClose]
from CompanyPriceHistory cph
join company c on c.CompanyID = cph.CompanyID 
) as tbl 
where tbl.[Percentage] <= -48 or tbl.[Percentage] >= 48
order by [Date] asc,[Percentage] asc
go


 