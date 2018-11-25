DECLARE @PageSize INT = 10, @PageIndex INT = 1;
DECLARE @Name varchar(max);
DECLARE @LastTradingDate date;
DECLARE @CompanyID int;
DECLARE @LastFundamentalDate date;
--set @LastFundamentalDate = '2018-11-18';

--{{PARAMS}}
if isnull(@Name,'')!=''
	begin
		set @Name = '%' + RTRIM(@Name) + '%';  
	end

--START SQL
select count(*) as [Count] from (
select c.CompanyID,(select max(cph.[Date]) from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID) as LastTradingDate from Company c
left outer join CompanyFundamental cf on cf.CompanyID = c.CompanyID
where (c.CompanyID = @CompanyID or @CompanyID is null) and (c.[CompanyName] like @Name or isnull(@Name,'')='')
and (cf.LastUpdatedDate is null or cf.LastUpdatedDate < @LastFundamentalDate or @LastFundamentalDate is null)
group by c.CompanyID 
) as tbl where 
(LastTradingDate is null or LastTradingDate < @LastTradingDate or @LastTradingDate is null)

select tbl.*,(case when LTDate is null then cast('2007-01-01' as date) else LTDate end) LastTradingDate from (
select c.*
,(select max(cph.[Date]) from CompanyPriceHistory cph where cph.CompanyID = c.CompanyID) as LTDate
from Company c
left outer join CompanyFundamental cf on cf.CompanyID = c.CompanyID
where (c.CompanyID = @CompanyID or @CompanyID is null) and (c.[CompanyName] like @Name or isnull(@Name,'')='')
and (cf.LastUpdatedDate is null or cf.LastUpdatedDate < @LastFundamentalDate or @LastFundamentalDate is null)
) as tbl where (LTDate is null or LTDate < @LastTradingDate or @LastTradingDate is null)
--{{ORDER_BY_START}}
order by [CompanyName] asc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
