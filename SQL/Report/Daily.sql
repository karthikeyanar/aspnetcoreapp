declare @PageSize INT = 20, @PageIndex INT = 1;
declare @fromDate date;
set @fromDate = GETDATE();
declare @toDate date;
set @toDate = GETDATE();
declare @isBookMarkCategory bit;
declare @isBookMark bit;
--set @isBookMarkCategory = 1;
--set @isBookMark = 1;
set @fromDate = '2018-10-27';
--set @toDate = '2018-12-03';

--{{PARAMS}}

--set @fromDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@fromDate)-1),@fromDate),101);

--select @fromDate as 'FromDate';

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)
insert into @TempBookMarkTable(CompanyID,IsBookMark)
select c.CompanyID,1 as BookMark from company c
left outer join companycategory cc on cc.companyid = c.companyid
left outer join category cat on cat.categoryid = cc.categoryid
where (cat.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null) 
and (c.IsBookMark = @isBookMark or @isBookMark is null)
and isnull(c.IsArchive,0) = 0
group by c.CompanyID

--select count(*) as [Count] from @TempBookMarkTable
declare @TempNiftyAverage table([Date] datetime,[Percentage] money)
insert into @TempNiftyAverage([Date],[Percentage])
select 
p.[Date]
,AVG((((p.[Close] - p.[Open])/p.[Open])*100)) as [Percentage]
from CompanyPriceHistory p
join Company company on company.CompanyID = p.CompanyID
where p.[Date] >= @fromDate
and p.[Date] <= @toDate
and company.Symbol = 'NIFTY50'
group by p.[Date]

--select * from @TempNiftyAverage 

declare @TempAverage table([Date] datetime,[Percentage] money)
insert into @TempAverage([Date],[Percentage])
select 
p.[Date]
,AVG((((p.[Close] - p.[Open])/p.[Open])*100)) as [Percentage]
from CompanyPriceHistory p
join @TempBookMarkTable tb on tb.CompanyID = p.CompanyID 
left outer join Company company on company.CompanyID = tb.CompanyID
where p.[Date] >= @fromDate
and p.[Date] <= @toDate
and (tb.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null)
group by p.[Date]
order by p.[Date] desc
--OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY

select count(*) as Count from @TempAverage 
  
select top 200 a.[Date],a.[Percentage],n.[Percentage] as Nifty from @TempAverage a
left outer join @TempNiftyAverage n on n.[Date] = a.Date
order by a.[Date] desc

--select sum(isnull(a.[Percentage],0)) as [Percentage],sum(isnull(n.[Percentage],0)) as Nifty from @TempAverage a
--left outer join @TempNiftyAverage n on n.[Date] = a.Date
