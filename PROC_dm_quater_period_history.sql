/****** Object:  StoredProcedure [dbo].[PROC_dm_quater_period_history]    Script Date: 03-Nov-18 6:50:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PROC_dm_quater_period_history]
   @symbol varchar(20),@date datetime
AS 

declare @year int;
set @year = YEAR(@date);
declare @month int;
set @month = MONTH(@date);

if @month >= 1 and @month <= 3  
	begin
		set @year = @year - 1;
	end

DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,dm_quater_period_id int
,[Year] int NULL
,[Quater] int NULL
,FromDate DateTime NULL
,ToDate DateTime NULL
) 

insert into @TempCalendar(dm_quater_period_id,[Year],[Quater],FromDate,ToDate)
select dm_quater_period_id,[Year],[Quater],FromDate,ToDate from dm_quater_period mp 
where [year] = @year;

declare @dm_quater_period_id int,@from_date datetime,@to_date datetime;

declare history_year_peiod_cursor CURSOR FOR  
   select dm_quater_period_id,FromDate,ToDate from @TempCalendar order by [dm_quater_period_id] asc

OPEN history_year_peiod_cursor; 

FETCH NEXT FROM history_year_peiod_cursor  
INTO @dm_quater_period_id,@from_date,@to_date; 

WHILE @@FETCH_STATUS = 0  
BEGIN  

declare @open decimal(19,4),@close decimal(19,4),@prev_open decimal(19,4),@prev_close decimal(19,4);

set @open = 0;set @close =0; set @prev_open=0; set @prev_close=0;

select top 1 @open = [Open] from EquityPriceHistory
where Symbol = @symbol and [Date] >= @from_date
order by [date] asc;
select top 1 @close = [Close] from EquityPriceHistory
where Symbol = @symbol and [Date] <= @to_date
order by [date] desc; 
--select @from_date as '@from_date',@open as '@open',@close as '@close',@prev_open as '@prev_open',@prev_close as '@prev_close';

declare @cnt int;
set @cnt = 0;

select @cnt = isnull(count(*),0) from dm_quater_period_history where symbol = @symbol and dm_quater_period_id = @dm_quater_period_id;

declare @percentage decimal(19,4);
set @percentage = 0;
if isnull(@close,0) > 0
	begin
		set @percentage = ((isnull(@close,0) - isnull(@open,0))/isnull(@open,0)) * 100;
	end 

if isnull(@percentage,0) != 0
	begin
		if isnull(@cnt,0) <= 0
			begin
				INSERT INTO [dbo].[dm_quater_period_history]
				   ([Symbol]
				   ,[dm_quater_period_id]
				   ,[percentage])
				VALUES
				   (@symbol
				   ,@dm_quater_period_id
				   ,@percentage)
			end
		else
			begin
				update [dbo].[dm_quater_period_history] set [percentage] = @percentage where symbol = @symbol and dm_quater_period_id = @dm_quater_period_id;
			end
	end

FETCH NEXT FROM history_year_peiod_cursor  
INTO @dm_quater_period_id,@from_date,@to_date; 

END  

CLOSE history_year_peiod_cursor;  
DEALLOCATE history_year_peiod_cursor; 

GO


/****** Object:  StoredProcedure [dbo].[PROC_dm_equity_period_history]    Script Date: 03-Nov-18 6:58:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PROC_dm_equity_period_history]
   @searchsymbol varchar(20)
AS  

DECLARE @TempGroup TABLE(
ID smallint Primary Key IDENTITY(1,1)
,[FromDate] datetime
) 

declare @mindate datetime,@maxdate datetime;
select @mindate = min([Date]), @maxdate = max([Date]) from EquityPriceHistory where Symbol = @searchsymbol;

declare @min_month_start_date datetime,@max_month_start_date datetime;
set @min_month_start_date = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@mindate)-1),@mindate),101);
set @max_month_start_date = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@maxdate)-1),@maxdate),101);

insert into @TempGroup([FromDate])
select [FromDate] from dm_month_period where FromDate >= @min_month_start_date and FromDate <= @max_month_start_date

DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempGroup);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempGroup);
select  @min_month_start_date as 'min_month_start_date',@max_month_start_date as 'max_month_start_date',@numrowsGroup as Total;
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		DECLARE @fromdate datetime;
		select @fromdate = [FromDate] from @TempGroup WHERE ID = @i;
		--select 'i:' + cast(@i as varchar(max));
        --Do something with Id here

		exec [dbo].[PROC_dm_month_period_history] @searchsymbol,@fromdate;
		exec [dbo].[PROC_dm_year_period_history] @searchsymbol,@fromdate;
		exec [dbo].[PROC_dm_quater_period_history] @searchsymbol,@fromdate;

        SET @i = @i + 1
    END
/******************** END LOOP *****************/


/****** Object:  StoredProcedure [dbo].[PROC_dm_quater_period_history]    Script Date: 03-Nov-18 7:01:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PROC_dm_quater_period_history]
   @symbol varchar(20),@date datetime
AS 

declare @year int;
set @year = YEAR(@date);
declare @month int;
set @month = MONTH(@date);

if @month >= 1 and @month <= 3  
	begin
		set @year = @year - 1;
	end

DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,dm_quater_period_id int
,[Year] int NULL
,[Quater] int NULL
,FromDate DateTime NULL
,ToDate DateTime NULL
) 

insert into @TempCalendar(dm_quater_period_id,[Year],[Quater],FromDate,ToDate)
select dm_quater_period_id,[Year],[Quater],FromDate,ToDate from dm_quater_period mp 
where [year] = @year;

declare @dm_quater_period_id int,@from_date datetime,@to_date datetime;

declare history_year_peiod_cursor CURSOR FOR  
   select dm_quater_period_id,FromDate,ToDate from @TempCalendar order by [dm_quater_period_id] asc

OPEN history_year_peiod_cursor; 

FETCH NEXT FROM history_year_peiod_cursor  
INTO @dm_quater_period_id,@from_date,@to_date; 

WHILE @@FETCH_STATUS = 0  
BEGIN  

declare @open decimal(19,4),@close decimal(19,4),@prev_open decimal(19,4),@prev_close decimal(19,4);

set @open = 0;set @close =0; set @prev_open=0; set @prev_close=0;

select top 1 @open = [Open] from EquityPriceHistory
where Symbol = @symbol and [Date] >= @from_date
order by [date] asc;
select top 1 @close = [Close] from EquityPriceHistory
where Symbol = @symbol and [Date] <= @to_date
order by [date] desc; 
--select @from_date as '@from_date',@open as '@open',@close as '@close',@prev_open as '@prev_open',@prev_close as '@prev_close';

declare @cnt int;
set @cnt = 0;

select @cnt = isnull(count(*),0) from dm_quater_period_history where symbol = @symbol and dm_quater_period_id = @dm_quater_period_id;

declare @percentage decimal(19,4);
set @percentage = 0;
if isnull(@open,0) > 0
	begin
		set @percentage = ((isnull(@close,0) - isnull(@open,0))/isnull(@open,0)) * 100;
	end 

if isnull(@percentage,0) != 0
	begin
		if isnull(@cnt,0) <= 0
			begin
				INSERT INTO [dbo].[dm_quater_period_history]
				   ([Symbol]
				   ,[dm_quater_period_id]
				   ,[percentage])
				VALUES
				   (@symbol
				   ,@dm_quater_period_id
				   ,@percentage)
			end
		else
			begin
				update [dbo].[dm_quater_period_history] set [percentage] = @percentage where symbol = @symbol and dm_quater_period_id = @dm_quater_period_id;
			end
	end

FETCH NEXT FROM history_year_peiod_cursor  
INTO @dm_quater_period_id,@from_date,@to_date; 

END  

CLOSE history_year_peiod_cursor;  
DEALLOCATE history_year_peiod_cursor; 

USE [DeepBlue]
GO
/****** Object:  StoredProcedure [dbo].[PROC_dm_quater_period_history]    Script Date: 03-Nov-18 7:03:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PROC_dm_quater_period_history]
   @symbol varchar(20),@date datetime
AS 

declare @year int;
set @year = YEAR(@date);
declare @month int;
set @month = MONTH(@date);

if @month >= 1 and @month <= 3  
	begin
		set @year = @year - 1;
	end

DECLARE @TempCalendar TABLE(
ID smallint Primary Key IDENTITY(1,1)
,dm_quater_period_id int
,[Year] int NULL
,[Quater] int NULL
,FromDate DateTime NULL
,ToDate DateTime NULL
) 

insert into @TempCalendar(dm_quater_period_id,[Year],[Quater],FromDate,ToDate)
select dm_quater_period_id,[Year],[Quater],FromDate,ToDate from dm_quater_period mp 
where [year] = @year;

declare @dm_quater_period_id int,@from_date datetime,@to_date datetime;

declare history_year_peiod_cursor CURSOR FOR  
   select dm_quater_period_id,FromDate,ToDate from @TempCalendar order by [dm_quater_period_id] asc

OPEN history_year_peiod_cursor; 

FETCH NEXT FROM history_year_peiod_cursor  
INTO @dm_quater_period_id,@from_date,@to_date; 

WHILE @@FETCH_STATUS = 0  
BEGIN  

declare @open decimal(19,4),@close decimal(19,4),@prev_open decimal(19,4),@prev_close decimal(19,4);

set @open = 0;set @close =0; set @prev_open=0; set @prev_close=0;

select top 1 @open = [Open] from EquityPriceHistory
where Symbol = @symbol and [Date] >= @from_date
order by [date] asc;
select top 1 @close = [Close] from EquityPriceHistory
where Symbol = @symbol and [Date] <= @to_date
order by [date] desc; 
--select @from_date as '@from_date',@open as '@open',@close as '@close',@prev_open as '@prev_open',@prev_close as '@prev_close';

declare @cnt int;
set @cnt = 0;

select @cnt = isnull(count(*),0) from dm_quater_period_history where symbol = @symbol and dm_quater_period_id = @dm_quater_period_id;

declare @percentage decimal(19,4);
set @percentage = 0;
if isnull(@open,0) > 0 and isnull(@close,0) > 0
	begin
		set @percentage = ((isnull(@close,0) - isnull(@open,0))/isnull(@open,0)) * 100;
	end 

if isnull(@percentage,0) != 0
	begin
		if isnull(@cnt,0) <= 0
			begin
				INSERT INTO [dbo].[dm_quater_period_history]
				   ([Symbol]
				   ,[dm_quater_period_id]
				   ,[percentage])
				VALUES
				   (@symbol
				   ,@dm_quater_period_id
				   ,@percentage)
			end
		else
			begin
				update [dbo].[dm_quater_period_history] set [percentage] = @percentage where symbol = @symbol and dm_quater_period_id = @dm_quater_period_id;
			end
	end

FETCH NEXT FROM history_year_peiod_cursor  
INTO @dm_quater_period_id,@from_date,@to_date; 

END  

CLOSE history_year_peiod_cursor;  
DEALLOCATE history_year_peiod_cursor; 

