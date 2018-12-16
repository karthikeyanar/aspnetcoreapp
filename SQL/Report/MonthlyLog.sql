declare @PageSize INT = 10, @PageIndex INT = 1;
declare @today date;
declare @fromDate date;
declare @toDate date;
declare @year int;
declare @isBookMarkCategory bit;
set @today = GETDATE();
set @isBookMarkCategory = 1;
set @year = 2007;

--{{PARAMS}}

if isnull(@year,0) > 0
	begin
		set @fromDate = CONVERT(DATE,(cast(isnull(@year,0) as varchar(max)) + '/04/01'));
		--set @toDate = CONVERT(DATE,(cast((isnull(@year,0)+1) as varchar(max)) + '/03/31'));
		set @toDate = CONVERT(DATE,(cast((YEAR(GetDate())+1) as varchar(max)) + '/03/31'));
	end

--select @fromDate as FromDate,@toDate as ToDate;

--select @fromDate as 'FromDate';

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)
insert into @TempBookMarkTable(CompanyID,IsBookMark)
select c.CompanyID,1 as BookMark from company c
left outer join companycategory cc on cc.companyid = c.companyid
left outer join category cat on cat.categoryid = cc.categoryid
where (cat.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null) 
group by c.CompanyID

set @fromDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@fromDate)-1),@fromDate),101);

DECLARE @TempLog TABLE(
ID smallint Primary Key IDENTITY(1,1)
,dm_month_period_id int
,Average decimal(19,4)
)

DECLARE @TempGroup TABLE(
ID smallint Primary Key IDENTITY(1,1)
,dm_month_period_id int
)
insert into @TempGroup(dm_month_period_id)
select dm_month_period_id from dm_month_period where (FromDate >= @fromDate or @fromDate is null) and (ToDate <= @toDate or @toDate is null)

DECLARE @i int; DECLARE @maxTempGroupID int; DECLARE @numrowsGroup int;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempGroup);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempGroup);
--select 'TotalRows:' + cast(@numrowsGroup as varchar(max));
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		DECLARE @id int;
		DECLARE @date datetime;
		select @id = dm_month_period_id from @TempGroup WHERE ID = @i;
		--select 'i:' + cast(@i as varchar(max));
        --Do something with Id here

		insert into @TempLog(dm_month_period_id,Average)
		select @id,AVG([Percentage]) as Average from (
			select 
			company.CompanyName 
			,company.Symbol
			,his.Percentage,his.PrevPercentage,p.FromDate,p.ToDate,p.PrevFromDate,p.PrevToDate 
			from dm_month_period p
			join dm_month_period_history his on his.dm_month_period_id = p.dm_month_period_id
			join @TempBookMarkTable tb on tb.CompanyID = his.CompanyID 
			left outer join Company company on company.CompanyID = tb.CompanyID
			where p.dm_month_period_id = @id
			and (tb.IsBookMark = @isBookMarkCategory or @isBookMarkCategory is null)
			--{{ORDER_BY_START}}
			order by his.prevpercentage desc
			--{{ORDER_BY_END}}
			OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
		) as tbl


        SET @i = @i + 1
    END
/******************** END LOOP *****************/

declare @initial_amount decimal(19,4);
declare @final_amount decimal(19,4);
set @initial_amount = 100000;
set @final_amount = @initial_amount;
set @i = 0; set @maxTempGroupID = 0; set @numrowsGroup = 0;
SET @maxTempGroupID = (SELECT MAX(ID) FROM @TempLog);
SET @numrowsGroup = (SELECT COUNT(*) FROM @TempLog);
--select 'TotalRows:' + cast(@numrowsGroup as varchar(max));
SET @i = 1;
IF @numrowsGroup > 0
    WHILE (@i <= @maxTempGroupID)
    BEGIN
		set @id = 0;
		declare @average decimal(19,4);
		select @id = dm_month_period_id,@average=isnull(Average,0) from @TempLog WHERE ID = @i;

		declare @profit decimal(19,4);
		set @profit = (isnull(@final_amount,0) * isnull(@average,0))/100;
		set @final_amount = isnull(@final_amount,0) + isnull(@profit,0);
		--select 'i:' + cast(@i as varchar(max));
        --Do something with Id here
        
		SET @i = @i + 1
    END

declare @nifty50ID int;
select @nifty50ID = isnull(CompanyID,0) from Company where Symbol = 'NIFTY50';
declare @nifty500ID int;
select @nifty500ID = isnull(CompanyID,0) from Company where Symbol = 'NIFTY500';
declare @month_end_date datetime;
set @month_end_date = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@today))),DATEADD(mm,1,@today)),101);

select p.FromDate,p.ToDate,plog.Average
--,nifty50his.[Percentage] as Nifty50,nifty500his.[Percentage] as Nifty500 
from @TempLog plog
join dm_month_period p on plog.dm_month_period_id = p.dm_month_period_id
--left outer join dm_month_period_history nifty50his on nifty50his.dm_month_period_id = p.dm_month_period_id and nifty50his.CompanyID = @nifty50ID
--left outer join dm_month_period_history nifty500his on nifty500his.dm_month_period_id = p.dm_month_period_id and nifty500his.CompanyID = @nifty500ID
where p.ToDate <= @month_end_date

select @initial_amount as 'Intial',@final_amount as 'Final',(((isnull(@final_amount,0) - isnull(@initial_amount,0))/isnull(@initial_amount,0))*100) as Profit;
