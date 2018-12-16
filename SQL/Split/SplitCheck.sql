select * from (
select c.CompanyID,c.CompanyName, c.Symbol, cph.[PrevClose] / cph.[Open] as SplitFactor
,cph.[Date] as SplitDate,((cph.[Open] - cph.[PrevClose])/cph.[PrevClose]) * 100 as [Percentage] 
,cph.[Open]
,cph.[PrevClose]
from CompanyPriceHistory cph
join company c on c.CompanyID = cph.CompanyID 
) as tbl 
where tbl.[Percentage] <= -40 or tbl.[Percentage] >= 40
order by [SplitDate] asc,[Percentage] asc
