declare @companyId int;
set @companyId = 270;

DECLARE @TempTable TABLE
(
   ID INT IDENTITY(1, 1),
   [Date] DATE,
   [Close] Decimal(19,4)
)

DECLARE @TempTable2 TABLE
(
   ID INT IDENTITY(1, 1),
   [Date] DATE,
   [Close] Decimal(19,4),
   MA50 Decimal(19,4),
   MA100 Decimal(19,4),
   MA200 Decimal(19,4),
   IsActive bit,
   Is100Active bit,
   Is50Active bit,
   LastActiveDate DATE,
   LastActivePrice decimal(19,4)
)
 
insert into @TempTable([Date],[Close])
select udlp.[Date],udlp.[Close] from CompanyPriceHistory udlp
where CompanyID = @companyId
order by udlp.[Date] asc

--SELECT [Date],
--       [Close],
--       AVG([Close]) OVER (ORDER BY [Date] ASC ROWS 49 PRECEDING) AS MA50
--FROM   @TempTable

--select * from @TempTable 

;WITH CTE_TempTable (ID,[Date], [Close],RowNumber,MA50,MA100,MA200)
AS
(
SELECT ID,[Date],
       [Close],
       ROW_NUMBER() OVER (ORDER BY [Date] ASC) RowNumber,
       AVG([Close]) OVER (ORDER BY [Date] ASC ROWS 49 PRECEDING) AS MA50,
	   AVG([Close]) OVER (ORDER BY [Date] ASC ROWS 99 PRECEDING) AS MA100,
       AVG([Close]) OVER (ORDER BY [Date] ASC ROWS 199 PRECEDING) AS MA200
FROM   @TempTable
)

insert into @TempTable2([Date],[Close],MA50,MA100,MA200,IsActive,Is100Active,Is50Active)
SELECT [Date],
       [Close],
	   MA50,
	   MA100,
	   MA200,
	   CASE WHEN RowNumber > 200 AND MA200 > [Close] THEN 0 ELSE 1 END,
	   CASE WHEN RowNumber > 200 AND MA100 > [Close] THEN 0 ELSE 1 END,
	   CASE WHEN RowNumber > 200 AND MA50 > [Close] THEN 0 ELSE 1 END
FROM   CTE_TempTable
ORDER BY [Date]

Declare @id int;
declare @isactive bit;
declare @is100active bit;
declare @is50active bit;
declare @isstop bit;
declare @is_set_stop bit;
declare @lastdate date;
declare @close decimal(19,4);

DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempTable2);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempTable2);
--select 'TotalRows:' + cast(@numrowsGroup as varchar(max));
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		set @id = 0;
		select @id = id,@isactive = isactive,@is100active = Is100Active,@is50active = Is50Active from @TempTable2 WHERE ID = @i;

		if isnull(@id,0) >= 200 
			begin
				--if @id = 1048 
				--	begin
				--		select @isactive,@is100active,@is50active,@isstop,@is_set_stop
				--	end

				if isnull(@isactive,0) = 0 --and isnull(@isactive,0) = 1
					begin
						set @isstop = 0;
						if isnull(@is_set_stop,0) = 0
							begin
								update @TempTable2 set LastActiveDate = @lastdate,LastActivePrice = @close where ID = (@id-1);
								set @is_set_stop = 1;
							end
					end

				if isnull(@isstop,0) = 0 and isnull(@isactive,0) = 1 --and isnull(@is50active,0) = 0
					begin
						set @is_set_stop = 0;
						select @lastdate = [Date],@close = [close] from @TempTable2 where ID = @id;
						--print @lastdate;
						set @isstop = 1;
					end
				--print @id;
			end
		 
        SET @i = @i + 1
    END
/******************** END LOOP *****************/

select * from @TempTable2 
--where isnull(AveragePrice,0) <> isnull(MA200,0)

DECLARE @TempGroup TABLE
(
   ID INT IDENTITY(1, 1),
   LastActiveDate DATE,
   LastActivePrice Decimal(19,4),
   [Date] DATE,
   [Close] Decimal(19,4),
   Change Decimal(19,4),
   [Days] int
)

--select LastActiveDate,LastActivePrice,[Close],[Date],Last50PriceDate,Last50Price
--,((((case when Last50Price > 0 then Last50Price else [Close] end) - LastActivePrice)/LastActivePrice)*100) as Change 
--,((([Close] - LastActivePrice)/LastActivePrice)*100) as Change2 
--from (
--select LastActiveDate,LastActivePrice,[Close],[Date]
--,(select top 1 [Date] from @TempTable2 t3 where t3.[Date] >= t2.LastActiveDate and t3.[Date] <= t2.[Date] and t3.Is50Active = 0 order by t3.[Date] asc) as Last50PriceDate
--,(select top 1 [Close] from @TempTable2 t3 where t3.[Date] >= t2.LastActiveDate and t3.[Date] <= t2.[Date] and t3.Is50Active = 0 order by t3.[Date] asc) as Last50Price 
--,((([Close] - LastActivePrice)/LastActivePrice)*100) as Change 
--,DATEDIFF(day, LastActiveDate, [Date]) as Days
--from @TempTable2 t2
--where LastActiveDate is not null and DATEDIFF(day, LastActiveDate, [Date]) > 0
--) as tbl

--select *,(MA200 - [Close]) as Diff from @TempTable2 
--where LastActiveDate is not null
insert into @TempGroup(LastActiveDate,LastActivePrice,[Close],[Date],Change,[Days])
select LastActiveDate,LastActivePrice,[Close],[Date]
,((([Close] - LastActivePrice)/LastActivePrice)*100) as Change 
,DATEDIFF(day, LastActiveDate, [Date]) as Days
from @TempTable2 t2
where LastActiveDate is not null and DATEDIFF(day, LastActiveDate, [Date]) > 0

--select * from @TempTable2 
select * from @TempGroup

DECLARE @TotalUnfunded decimal(19,4);
set @TotalUnfunded = 100000;
DECLARE @CurrentUnfunded decimal(19,4);
set @CurrentUnfunded = @TotalUnfunded;
set @i = 0; set @maxTempGroupID = 0; set @numrowsGroup = 0;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempGroup);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempGroup);
--select 'TotalRows:' + cast(@numrowsGroup as varchar(max));
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		set @id = 0;
		declare @change decimal(19,4);
		select @id = ID,@change = Change from @TempGroup WHERE ID = @i;

		set @CurrentUnfunded = @CurrentUnfunded + ((@CurrentUnfunded * @change)/100);

		--if @id = 1
		--	begin
		--		select (@CurrentUnfunded * @change)/100, @change as change;
		--	end
		--select 'i:' + cast(@i as varchar(max)),'DealID:' + cast(@dealid as varchar(max));
        --Do something with Id here
        --exec [dbo].[PROC_UpdateDealDetail] @dealid;

        SET @i = @i + 1
    END
/******************** END LOOP *****************/

select @TotalUnfunded as TotalUnfunded,@CurrentUnfunded as CurrentUnfunded,(((@CurrentUnfunded - @TotalUnfunded)/@TotalUnfunded)*100) as Change;