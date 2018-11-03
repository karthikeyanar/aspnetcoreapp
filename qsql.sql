/****** Object:  Table [dbo].[dm_time_period]    Script Date: 9/15/2018 11:57:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dm_month_period](
	[dm_month_period_id] [int] IDENTITY(1,1) NOT NULL,
	[PrevMonthCount] [int] NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NOT NULL,
	[PrevFromDate] [datetime] NOT NULL,
	[PrevToDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dm_month_period] PRIMARY KEY CLUSTERED 
(
	[dm_month_period_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[dm_year_period]    Script Date: 9/15/2018 11:57:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dm_year_period](
	[dm_year_period_id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dm_year_period] PRIMARY KEY CLUSTERED 
(
	[dm_year_period_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/***************************************************/
DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,QStartDate DateTime NULL
,QLastDate DateTime NULL
) 
declare @Start_Date date= '2007-01-01';
declare @End_Date date= '2038-01-01';
declare @PreMonthCount int = 6;

declare @TotalYears int;
select @TotalYears = (Year(@End_Date) - Year(@Start_Date));
select @TotalYears as Diff;
declare @i int;
set @i = 0;
--if (Year(@End_Date) - Year(@Start_Date)) > 2
--begin
	--set @Start_Date = DATEADD(Year,DATEDIFF(YEAR,0, @End_Date),0);
	--set @Start_Date = DATEADD(Year,-2, @Start_Date);
	/*set @End_Date = DATEADD(Year,DATEDIFF(YEAR,0, GETDATE()),0);
	set @End_Date = DATEADD(Year,1, @End_Date);*/
--end
WHILE (@i <= @TotalYears)
BEGIN
    --select @i as '@i';
	declare @year as datetime;
	SET @year = DATEADD(year,@i,@Start_Date);
	--SELECT RIGHT('0' + DATENAME(DAY, @year), 2) + ' ' + DATENAME(MONTH, @year)+ ' ' + DATENAME(YEAR, @year) AS [Year]
	declare @q as int;
	set @q = 0;
	WHILE (@q <= 11)
		BEGIN
			declare @targetdate datetime;
			set @targetdate = DATEADD(MONTH,@q,@year);

			--SELECT @q as q,RIGHT('0' + DATENAME(DAY, @targetdate), 2) + ' ' + DATENAME(MONTH, @targetdate)+ ' ' + DATENAME(YEAR, @targetdate) AS [DD Month YYYY]

			declare @fromdate datetime,@todate datetime,@prevfromdate datetime,@prevtodate datetime;
			set @fromdate = DATEADD(dd,-(DAY(@targetdate)-1),@targetdate);
			set @todate = DATEADD(dd,-(DAY(DATEADD(mm,1,@targetdate))),DATEADD(mm,1,@targetdate)); 
			
			set @prevtodate = DATEADD(dd,-(DAY(DATEADD(mm,1,DATEADD(dd,-1,@fromdate)))),DATEADD(mm,1,DATEADD(dd,-1,@fromdate)));
			set @prevfromdate = DATEADD(dd,-(DAY(DATEADD(mm,-(@PreMonthCount-1),@prevtodate))-1),DATEADD(mm,-(@PreMonthCount-1),@prevtodate));

			--select @prevfromdate as '@prevfromdate';

			declare @cnt int = 0;
			select @cnt = isnull(count(*),0) from [dm_month_period] where [PrevMonthCount] = @PreMonthCount and [FromDate] = @fromdate and [ToDate] = @todate;

			if isnull(@cnt,0) = 0 
				begin
					insert into [dm_month_period]([PrevMonthCount],[FromDate],[ToDate],[PrevFromDate],[PrevToDate]) 
					values (@PreMonthCount,@fromdate,@todate,@prevfromdate,@prevtodate);
				end
			
			SET @q = @q + 1;
		END
    SET @i = @i + 1;
END
/***************************************************/

/***************************************************/
DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,QStartDate DateTime NULL
,QLastDate DateTime NULL
) 
declare @Start_Date date= '2007-01-01';
declare @End_Date date= '2038-01-01';
declare @PreMonthCount int = 6;

declare @TotalYears int;
select @TotalYears = (Year(@End_Date) - Year(@Start_Date));
select @TotalYears as Diff;
declare @i int;
set @i = 0;
--if (Year(@End_Date) - Year(@Start_Date)) > 2
--begin
	--set @Start_Date = DATEADD(Year,DATEDIFF(YEAR,0, @End_Date),0);
	--set @Start_Date = DATEADD(Year,-2, @Start_Date);
	/*set @End_Date = DATEADD(Year,DATEDIFF(YEAR,0, GETDATE()),0);
	set @End_Date = DATEADD(Year,1, @End_Date);*/
--end
WHILE (@i <= @TotalYears)
BEGIN
    --select @i as '@i';
	declare @year as int;
	SET @year = YEAR(DATEADD(year,@i,@Start_Date));

	declare @fromdate datetime;
	declare @todate datetime;

	set @fromdate = cast('04/01/'+cast(@year as varchar(max)) as datetime);
	set @todate = cast('03/31/'+cast((@year+1) as varchar(max)) as datetime);
 
	declare @cnt int = 0;
	select @cnt = isnull(count(*),0) from [dm_year_period] where [Year] = @year and [FromDate] = @fromdate and [ToDate] = @todate;

	if isnull(@cnt,0) = 0 
		begin
			insert into [dm_year_period]([Year],[FromDate],[ToDate]) 
			values (@year,@fromdate,@todate);
		end
	SET @i = @i + 1;
END
/***************************************************/
 
CREATE TABLE [dbo].[EquityPriceHistory] (
  [Symbol] varchar(20) NOT NULL,
  [Date] datetime NOT NULL,
  [Open] decimal(19, 4) NULL,
  [Low] decimal(19, 4) NULL,
  [High] decimal(19, 4) NULL,
  [Close] decimal(19, 4) NULL,
  [PrevClose] decimal(19, 4) NULL,
  [HeiOpen] decimal(19, 4) NULL,
  [HeiLow] decimal(19, 4) NULL,
  [HeiHigh] decimal(19, 4) NULL,
  [HeiClose] decimal(19, 4) NULL,
  [IsGreen] bit NULL,
  [IsRed] bit NULL,
  [GreenDays] int NULL,
  [RedDays] int NULL,
  PRIMARY KEY CLUSTERED ([Symbol], [Date])
)
GO
/****** Object:  Table [dbo].[EquityPriceSplit]    Script Date: 9/15/2018 4:13:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EquityPriceSplit](
	[EquityPriceSplitID] [int] IDENTITY(1,1) NOT NULL,
	[Symbol] [varchar](20) NULL,
	[SplitFactor] [decimal](19, 12) NULL,
	[SplitDate] [datetime] NULL,
 CONSTRAINT [PK_EquityPriceSplitID] PRIMARY KEY CLUSTERED 
(
	[EquityPriceSplitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

alter table [EquityPriceHistory] ADD OriginalOpen decimal(19,4)
GO
alter table [EquityPriceHistory] ADD OriginalLow decimal(19,4)
GO
alter table [EquityPriceHistory] ADD OriginalHigh decimal(19,4)
GO
alter table [EquityPriceHistory] ADD OriginalClose decimal(19,4)
GO
alter table [EquityPriceHistory] ADD OriginalPrevClose decimal(19,4)
GO


/****** Object:  StoredProcedure [dbo].[PROC_UpdateEquityPriceHistory]    Script Date: 9/21/2018 11:56:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PROC_UpdateEquityPriceHistory]
   @symbol varchar(20)
AS 

declare @Temp as Table
    (
		ID INT IDENTITY(1, 1),
		[Date] datetime,
		[Open] decimal(19,4),
		[Low] decimal(19,4),
		[High] decimal(19,4),
		[Close] decimal(19,4),
		[HeiOpen] decimal(19,4),
		[HeiLow] decimal(19,4),
		[HeiHigh] decimal(19,4),
		[HeiClose] decimal(19,4)
    );

insert into @Temp([Date],[Open],[Low],[High],[Close],[HeiClose]) 
select [Date],[Open],[Low],[High],[Close],(isnull([Open],0) + isnull([Low],0) + isnull([High],0) + isnull([Close],0)) / 4 from EquityPriceHistory 
where Symbol = @symbol
order by [date] asc

--select * from @Temp;

declare @id as int,@date datetime,@open decimal(19,4),@low decimal(19,4),@high decimal(19,4),@close decimal(19,4),@heiclose decimal(19,4);

declare history_cursor CURSOR FOR  
   select [ID],[Date],[Open],[Low],[High],[Close],[HeiClose] from @Temp order by [date] asc

OPEN history_cursor; 

FETCH NEXT FROM history_cursor  
INTO @id,@date,@open,@low,@high,@close,@heiclose; 

WHILE @@FETCH_STATUS = 0  
BEGIN  

declare @heiopen decimal(19,4),@heilow decimal(19,4),@heihigh decimal(19,4);

if isnull(@id,0) = 1 
	begin
		set @heiopen = @open;set @heilow = @low;set @heihigh = @high;
	end
else
	begin
		declare @prevheiopen decimal(19,4);
		declare @prevheiclose decimal(19,4);
		select top 1 @prevheiopen = isnull(heiopen,0),@prevheiclose = isnull(heiclose,0) from @Temp where id < @id order by id desc;

		set @heiopen = (isnull(@prevheiopen,0) + isnull(@prevheiclose,0))/2;
		select @heihigh = MAX(v)
			from (values (@high), (@heiopen), (@heiclose)) AS value(v);
		select @heilow = MIN(v)
			from (values (@low), (@heiopen), (@heiclose)) AS value(v);
	end

update @Temp set heiopen = @heiopen,heilow = @heilow,heihigh = @heihigh,heiclose = @heiclose where id = @id;

update EquityPriceHistory set HeiOpen = @heiopen,HeiClose = @heiclose,HeiHigh = @heihigh,HeiLow = @heilow,IsRed = (case when @heiopen = @heihigh then 1 else 0 end),IsGreen = (case when @heiopen = @heilow then 1 else 0 end) where Symbol = @symbol and [Date] = @date;

--select @heiclose as '@heiclose';

--select @date as [date],@close as [close];

FETCH NEXT FROM history_cursor  
INTO @id,@date,@open,@low,@high,@close,@heiclose; 

END  


CLOSE history_cursor;  
DEALLOCATE history_cursor; 

/****** Object:  Table [dbo].[dm_moth_period_history]    Script Date: 9/21/2018 12:51:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dm_moth_period_history](
	[dm_moth_period_history_id] [int] IDENTITY(1,1) NOT NULL,
	[Symbol] [varchar](20) NOT NULL,
	[dm_month_period_id] [int] NOT NULL,
	[percentage] [decimal](19,4) NULL,
	[prev_percentage] [decimal](19,4) NULL,
 CONSTRAINT [PK_dm_moth_period_history] PRIMARY KEY CLUSTERED 
(
	[dm_moth_period_history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




select his.*
,REPLACE(CONVERT(VARCHAR(11), mp.FromDate, 106), ' ', '-') as FromDate
,REPLACE(CONVERT(VARCHAR(11), mp.ToDate, 106), ' ', '-') as ToDate
,(select top 1  [Open] from EquityPriceHistory
where Symbol = his.Symbol and [Date] >= mp.FromDate
order by [date] asc) as [Open]
,(select top 1  [Close] from EquityPriceHistory
where Symbol = his.Symbol and [Date] <= mp.ToDate
order by [date] desc) as [Close]
,(select top 1  [Open] from EquityPriceHistory
where Symbol = his.Symbol and [Date] >= mp.PrevFromDate
order by [date] asc) as [Prev_Open]
,(select top 1  [Close] from EquityPriceHistory
where Symbol = his.Symbol and [Date] <= mp.PrevToDate
order by [date] desc) as [Prev_Close]
,REPLACE(CONVERT(VARCHAR(11), mp.PrevFromDate, 106), ' ', '-') as PrevFromDate
,REPLACE(CONVERT(VARCHAR(11), mp.PrevToDate, 106), ' ', '-') as PrevToDate
from dm_month_period_history his
join dm_month_period mp on his.dm_month_period_id = mp.dm_month_period_id
order by his.symbol asc,mp.fromdate asc
go



 