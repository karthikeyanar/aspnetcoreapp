declare @FromDate datetime;
declare @PageIndex int;
declare @PageSize int;
declare @IsBookMarkCategory bit;

set @PageIndex = 1;
set @PageSize = 10;
set @FromDate = '2018/12/01';
set @IsBookMarkCategory = 1;

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)
insert into @TempBookMarkTable(CompanyID,IsBookMark)
select c.CompanyID,1 as BookMark from company c
left outer join companycategory cc on cc.companyid = c.companyid
left outer join category cat on cat.categoryid = cc.categoryid
where (cat.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null) 
group by c.CompanyID
 
DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,[Date] DateTime NULL
,Average decimal(19,4)
,TotalCompany int
)

DECLARE @TempCompanyIDs TABLE(
ID smallint Primary Key IDENTITY(1,1)
,CompanyID int NOT NULL
,CompanyName varchar(max) NOT NULL
)

declare @monthStartDate datetime,@monthEndDate datetime;
set @monthStartDate = CONVERT(date,DATEADD(month,0,@fromDate));
set @monthEndDate = CONVERT(date,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@monthStartDate)+1,0)));

--select @monthStartDate as 'MonthStartDate',@monthEndDate as 'MonthEndDate';

delete from @TempCompanyIDs;

insert into @TempCompanyIDs(CompanyID,CompanyName) 
select his.CompanyID,c.CompanyName from dm_month_period_history his
join dm_month_period mp on mp.dm_month_period_id = his.dm_month_period_id
join Company c on c.CompanyID = his.CompanyID
join @TempBookMarkTable tb on tb.CompanyID = his.CompanyID 
where mp.FromDate = @monthStartDate and mp.ToDate = @monthEndDate
order by his.prevpercentage desc
OFFSET (@PageIndex-1)*@PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY

--select * from @TempCompanyIDs

DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;

SET @maxTempGroupID = 31; 
SET @i = 0;
WHILE (@i <= @maxTempGroupID)
BEGIN

	declare @today datetime;
	set @today = CONVERT(date,DATEADD(day,@i,@monthStartDate));
	--select @monthStartDate as 'MonthStartDate',@today as 'Today';
	IF @monthEndDate >= @today 
		BEGIN
			insert into @TempCalendar([Date],Average,TotalCompany)
			select @today
			,AVG(perc)
			,(select isnull(count(*),0) from @TempCompanyIDs) as TotalCompany from (
			select tbl.*,((isnull(tbl.[Close],0) - isnull(tbl.[Open],0)) / isnull(tbl.[Open],0)) * 100 as Perc  from (
			select e.CompanyID
			,(select top 1 isnull(his.[Open],0) from CompanyPriceHistory his where his.CompanyID = e.CompanyID and his.[Date] >= @monthStartDate order by his.[Date] asc) as [Open]  
			,(select top 1 isnull(his.[Close],0) from CompanyPriceHistory his where his.CompanyID = e.CompanyID and his.[Date] <= @today order by his.[Date] desc) as [Close]
			from @TempCompanyIDs e
			) as tbl where tbl.[Open] > 0) as tbl2
		END

    SET @i = @i + 1
END
select t.*,t.Average - (select top 1 [Average] from @TempCalendar where [Date] < t.[Date] order by [date] desc) as Change from @TempCalendar t 