declare @PageSize INT = 10, @PageIndex INT = 1;
declare @fromDate date;
set @fromDate = GETDATE();
declare @isBookMarkCategory bit;
set @isBookMarkCategory = 1;

--{{PARAMS}}

set @fromDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@fromDate)-1),@fromDate),101);

--select @fromDate as 'FromDate';

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)
insert into @TempBookMarkTable(CompanyID,IsBookMark)
select c.CompanyID,1 as BookMark from company c
left outer join companycategory cc on cc.companyid = c.companyid
left outer join category cat on cat.categoryid = cc.categoryid
where (cat.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null) 
group by c.CompanyID

select count(*) as [Count] from @TempBookMarkTable

select 
company.CompanyName 
,company.Symbol
,his.Percentage,his.PrevPercentage,p.FromDate,p.ToDate,p.PrevFromDate,p.PrevToDate
,company.InvestingUrl
,company.LastTradingDate
,company.CompanyID
from dm_month_period p
join dm_month_period_history his on his.dm_month_period_id = p.dm_month_period_id
join @TempBookMarkTable tb on tb.CompanyID = his.CompanyID 
left outer join Company company on company.CompanyID = tb.CompanyID
where p.FromDate = @fromDate
and (tb.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null)
--{{ORDER_BY_START}}
order by his.prevpercentage desc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
 