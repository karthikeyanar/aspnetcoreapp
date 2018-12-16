DECLARE @TempGroup TABLE(
ID smallint Primary Key IDENTITY(1,1)
,EquityPriceSplitID int
)
insert into @TempGroup(EquityPriceSplitID)
select EquityPriceSplitID from EquityPriceSplit

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
		select @id = EquityPriceSplitID from @TempGroup WHERE ID = @i;

		delete from EquityPriceSplit where EquityPriceSplitID = @id;
		--select 'i:' + cast(@i as varchar(max));
        --Do something with Id here
        --exec [dbo].[PROC_dm_equity_period_history] @id;
        SET @i = @i + 1
    END
/******************** END LOOP *****************/