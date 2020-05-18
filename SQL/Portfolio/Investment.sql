DECLARE @PageSize INT = 10000, @PageIndex INT = 1;
DECLARE @CompanyIDs varchar(max);
declare @ID int;

--{{PARAMS}} 

select count(*) as [Count] from (
select tbl.*
,(tbl.Quantity * tbl.ClosePrice) as CurrentMarketValue 
,(((tbl.Quantity * tbl.ClosePrice) - tbl.TotalInvestment) / (tbl.Quantity * tbl.ClosePrice)) * 100 as ProfitPercentage
from (
select c.CompanyName,c.Symbol
,p.*,p.Quantity * p.AverageCost as TotalInvestment 
,(select top 1 his.[Close] from CompanyPriceHistory his where his.CompanyID = p.CompanyID order by his.[Date] desc) as ClosePrice
from Portfolio p
join Company c on c.CompanyID = p.CompanyID 
) as tbl
) as tbl2 

select * from (
select tbl.*
,(tbl.Quantity * tbl.ClosePrice) as CurrentMarketValue 
,(((tbl.Quantity * tbl.ClosePrice) - tbl.TotalInvestment) / (tbl.Quantity * tbl.ClosePrice)) * 100 as ProfitPercentage
from (
select c.CompanyName,c.Symbol
,(select top 1 cat.CategoryName from CompanyCategory cc 
join Category cat on cat.CategoryID = cc.CategoryID 
where cc.CompanyID = p.CompanyID 
and cat.IsBookMark = 1
) as CategoryName
,p.*,p.Quantity * p.AverageCost as TotalInvestment 
,(select top 1 his.[Close] from CompanyPriceHistory his where his.CompanyID = p.CompanyID order by his.[Date] desc) as ClosePrice
from Portfolio p
join Company c on c.CompanyID = p.CompanyID 
) as tbl
) as tbl2 
--{{ORDER_BY_START}}
order by ProfitPercentage desc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
 
