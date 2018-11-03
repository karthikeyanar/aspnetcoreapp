declare @FromDate datetime;
declare @PageIndex int;
declare @PageSize int;

set @PageIndex = 1;
set @PageSize = 10;
set @FromDate = '01/01/2018';
 
DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,[Date] DateTime NULL
,Average decimal(19,4)
,TotalEquity int
)

DECLARE @TempSymbols TABLE(
ID smallint Primary Key IDENTITY(1,1)
,Symbol varchar(max) NOT NULL
)

declare @monthStartDate datetime,@monthEndDate datetime;
set @monthStartDate = CONVERT(date,DATEADD(month,0,@fromDate));
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
			insert into @TempCalendar([Date],Average,TotalEquity)
			select @today
			,AVG(perc)
			,(select isnull(count(*),0) from @TempSymbols) as TotalEquity from (
			select tbl.*,((isnull(tbl.[Close],0) - isnull(tbl.[Open],0)) / isnull(tbl.[Open],0)) * 100 as Perc  from (
			select e.Symbol
			,(select top 1 isnull(his.[Open],0) from EquityPriceHistory his where his.Symbol = e.Symbol and his.[Date] >= @monthStartDate order by his.[Date] asc) as [Open]  
			,(select top 1 isnull(his.[Close],0) from EquityPriceHistory his where his.Symbol = e.Symbol and his.[Date] <= @today order by his.[Date] desc) as [Close]
			from @TempSymbols e
			) as tbl where tbl.[Open] > 0) as tbl2
		END

    SET @i = @i + 1
END
select t.*,t.Average - (select top 1 [Average] from @TempCalendar where [Date] < t.[Date] order by [date] desc) as Change from @TempCalendar t 