DECLARE @TempGroup TABLE(
ID smallint Primary Key IDENTITY(1,1)
,CompanyID int
,[SplitDate] datetime
,[SplitFactor] decimal(19,12)
)
insert into @TempGroup(CompanyID,SplitDate,SplitFactor)
select CompanyID,[Date],SplitFactor from (
select c.CompanyID,c.CompanyName, c.Symbol, cph.[PrevClose] / cph.[Open] as SplitFactor
,cph.[Date],((cph.[Open] - cph.[PrevClose])/cph.[PrevClose]) * 100 as [Percentage] 
,cph.[Open]
,cph.[PrevClose]
from CompanyPriceHistory cph
join company c on c.CompanyID = cph.CompanyID 
) as tbl 
where tbl.[Percentage] <= -48 or tbl.[Percentage] >= 48
order by [Date] asc,[Percentage] asc

select * from @TempGroup

DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempGroup);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempGroup);
select 'TotalRows:' + cast(@numrowsGroup as varchar(max));
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		DECLARE @id int;
		DECLARE @date datetime;
		DECLARE @factor decimal(19,12);
		select @id = CompanyID,@date = SplitDate,@factor = SplitFactor from @TempGroup WHERE ID = @i;

		insert into EquityPriceSplit(CompanyID,SplitFactor,SplitDate)
		values (@id,@factor,@date)
		--select 'i:' + cast(@i as varchar(max));
        --Do something with Id here
        --exec [dbo].[PROC_dm_equity_period_history] @id;
        SET @i = @i + 1
    END
/******************** END LOOP *****************/