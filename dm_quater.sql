/****** Object:  Table [dbo].[dm_quater_period]    Script Date: 03-Nov-18 6:39:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dm_quater_period](
	[dm_quater_period_id] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Quater] [int] NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dm_quater_period] PRIMARY KEY CLUSTERED 
(
	[dm_quater_period_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[dm_quater_period_history]    Script Date: 03-Nov-18 6:49:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dm_quater_period_history](
	[Symbol] [varchar](20) NOT NULL,
	[dm_quater_period_id] [int] NOT NULL,
	[percentage] [decimal](19, 4) NULL,
 CONSTRAINT [PK_dm_quater_period_history] PRIMARY KEY CLUSTERED 
(
	[dm_quater_period_id] ASC,
	[Symbol] ASC
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
declare @i int,@j int;
set @i = 0;
set @j = 0;
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

	set @j = 0;
	WHILE (@j <= 4)
	BEGIN

		declare @fromdate datetime;
		declare @todate datetime;
		
		--select @j as 'j';
		IF @j = 0
			BEGIN
				set @fromdate = cast('04/01/'+cast(@year as varchar(max)) as datetime);
				set @todate = cast('06/30/'+cast((@year) as varchar(max)) as datetime);
			END
		ELSE IF @j = 1
			BEGIN
				set @fromdate = cast('07/01/'+cast(@year as varchar(max)) as datetime);
				set @todate = cast('09/30/'+cast((@year) as varchar(max)) as datetime);
			END
		ELSE IF @j = 2
			BEGIN
				set @fromdate = cast('10/01/'+cast(@year as varchar(max)) as datetime);
				set @todate = cast('12/31/'+cast((@year) as varchar(max)) as datetime);
			END
		ELSE IF @j = 3
			BEGIN
				set @fromdate = cast('01/01/'+cast((@year+1) as varchar(max)) as datetime);
				set @todate = cast('03/31/'+cast((@year+1) as varchar(max)) as datetime);
			END
 
		declare @cnt int = 0;
		select @cnt = isnull(count(*),0) from [dm_quater_period] where [Year] = @year and [FromDate] = @fromdate and [ToDate] = @todate;

		if isnull(@cnt,0) = 0 
			begin
				insert into [dm_quater_period]([Year],[Quater],[FromDate],[ToDate]) 
				values (@year,(@j+1),@fromdate,@todate);
			end

		SET @j = @j + 1;
	END
	SET @i = @i + 1;
END
/***************************************************/