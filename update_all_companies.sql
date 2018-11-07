DECLARE @TempGroup TABLE(
ID smallint Primary Key IDENTITY(1,1)
,CompanyID int
)
insert into @TempGroup(CompanyID)
select CompanyID from CompanyPriceHistory Group By CompanyID

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
		select @id = CompanyID from @TempGroup WHERE ID = @i;
		--select 'i:' + cast(@i as varchar(max));
        --Do something with Id here
        exec [dbo].[PROC_dm_equity_period_history] @id;
        SET @i = @i + 1
    END
/******************** END LOOP *****************/