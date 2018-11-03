declare @year int;
declare @PageIndex int;
declare @PageSize int;

set @PageIndex = 1;
set @PageSize = 10;
set @year = 2018;
 
DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,FromDate DateTime NULL
,ToDate DateTime NULL
,Average decimal(19,4)
,TotalEquity int
)

DECLARE @TempSymbols TABLE(
ID smallint Primary Key IDENTITY(1,1)
,Symbol varchar(max) NOT NULL
)

declare @fromDate datetime,@toDate datetime; 

select @fromDate=FromDate,@toDate=ToDate from dm_year_period where [Year] = @year;

DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;

SET @maxTempGroupID = 11; 
SET @i = 0;
WHILE (@i <= @maxTempGroupID)
BEGIN
	declare @monthStartDate datetime,@monthEndDate datetime;
	set @monthStartDate = CONVERT(date,DATEADD(month,@i,@fromDate));
	set @monthEndDate = CONVERT(date,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@monthStartDate)+1,0)));
	--select @monthStartDate as 'MonthStartDate',@monthEndDate as 'MonthEndDate';

	delete from @TempSymbols;

	insert into @TempSymbols(Symbol) 
	select Symbol from dm_month_period_history his
	join dm_month_period mp on mp.dm_month_period_id = his.dm_month_period_id
	where mp.FromDate = @monthStartDate and mp.ToDate = @monthEndDate
	order by his.prev_percentage desc
	OFFSET (@PageIndex-1)*@PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY

	insert into @TempCalendar(FromDate,ToDate,Average,TotalEquity)
	select @monthStartDate,@monthEndDate,AVG(perc),(select isnull(count(*),0) from @TempSymbols) as TotalEquity from (
	select tbl.*,((isnull(tbl.[Close],0) - isnull(tbl.[Open],0)) / isnull(tbl.[Open],0)) * 100 as Perc  from (
	select e.Symbol
	,(select top 1 isnull(his.[Open],0) from EquityPriceHistory his where his.Symbol = e.Symbol and his.[Date] >= @monthStartDate order by his.[Date] asc) as [Open]  
	,(select top 1 isnull(his.[Close],0) from EquityPriceHistory his where his.Symbol = e.Symbol and his.[Date] <= @monthEndDate order by his.[Date] desc) as [Close]
	from @TempSymbols e
	) as tbl where tbl.[Open] > 0) as tbl2

    SET @i = @i + 1
END
select * from @TempCalendar 
select sum(Average) from @TempCalendar 