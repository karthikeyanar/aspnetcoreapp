declare @PageSize INT = 10, @PageIndex INT = 1;
declare @fromDate date;
set @fromDate = '11/03/2018';
declare @isBookMarkCategory bit;
set @isBookMarkCategory = 1;

--{{PARAMS}}

set @fromDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@fromDate)-1),@fromDate),101);

--select @fromDate as 'FromDate';

declare @TempBookMarkTable table(Symbol varchar(20),IsBookMark bit)
insert into @TempBookMarkTable(Symbol,IsBookMark)
select c.symbol,1 as BookMark from company c
join companycategory cc on cc.companyid = c.companyid
join category cat on cat.categoryid = cc.categoryid
where (cat.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null) 
group by c.symbol

select count(*) as [Count] from @TempBookMarkTable

select 
company.CompanyName 
,his.Symbol
,his.Percentage,his.PrevPercentage,p.FromDate,p.ToDate,p.PrevFromDate,p.PrevToDate 
from dm_month_period p
join dm_month_period_history his on his.dm_month_period_id = p.dm_month_period_id
join @TempBookMarkTable tb on tb.Symbol = his.Symbol 
left outer join Company company on company.Symbol = tb.Symbol
where p.FromDate = @fromDate
and (tb.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null)
--{{ORDER_BY_START}}
order by his.prevpercentage desc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
