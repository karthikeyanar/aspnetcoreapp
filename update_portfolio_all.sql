DECLARE @TempGroup TABLE(
ID smallint Primary Key IDENTITY(1,1)
,CompanyID int NOT NULL
)
insert into @TempGroup(CompanyID)
select  companyid from PortfolioTransaction 
group by companyid
DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempGroup);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempGroup);
select 'TotalRows:' + cast(@numrowsGroup as varchar(max));
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		DECLARE @companyid int;
		select @companyid = CompanyID from @TempGroup WHERE ID = @i;
		exec [PROC_Portfolio] @companyid;
        SET @i = @i + 1
    END
/******************** END LOOP *****************/ 