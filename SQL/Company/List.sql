DECLARE @PageSize INT = 10, @PageIndex INT = 1;
DECLARE @Name varchar(max);
DECLARE @LastTradingDate date;
DECLARE @CompanyID int;
DECLARE @LastFundamentalDate date;
DECLARE @CompanyIDs varchar(max);
DECLARE @CategoryIDs varchar(max);
declare @isBookMarkCategory bit;
--set @LastTradingDate  = '2018-11-22';
--set @CategoryIDs = '1';
--set @LastFundamentalDate = '2018-11-18';

--{{PARAMS}}
if isnull(@Name,'')!=''
	begin
		set @Name = '%' + RTRIM(@Name) + '%';  
	end

declare @TempBookMarkTable table(CompanyID int,IsBookMark bit)

if isnull(@isBookMarkCategory,0) = 1
	begin
		insert into @TempBookMarkTable(CompanyID,IsBookMark)
		select c.CompanyID,1 as BookMark from company c
		left outer join companycategory cc on cc.companyid = c.companyid
		left outer join category cat on cat.categoryid = cc.categoryid
		where cat.IsBookMark = 1
		group by c.CompanyID
	end

DECLARE @CompanyParamTable TABLE
(
ID int
)
DECLARE @CategoryParamTable TABLE
(
ID int
)
DECLARE @SQL varchar(max);

SELECT @SQL = 'SELECT ''' + REPLACE (@CompanyIDs,',',''' UNION SELECT ''') + ''''
INSERT INTO @CompanyParamTable (ID) EXEC (@SQL)

SELECT @SQL = 'SELECT ''' + REPLACE (@CategoryIDs,',',''' UNION SELECT ''') + ''''
INSERT INTO @CategoryParamTable (ID) EXEC (@SQL)
 
--select * from @CompanyParamTable 
declare @TempCategoryTable table(CompanyID int)
if isnull(@CategoryIDs,'') != ''
	begin
		insert into @TempCategoryTable(CompanyID)
		select cc.CompanyID from companycategory cc
		join category cat on cat.categoryid = cc.categoryid
		join @CategoryParamTable cpt on cpt.ID = cat.CategoryID 
		group by cc.CompanyID
	end

--START SQL 
select count(*) as [Count]
from Company c
left outer join CompanyFundamental cf on cf.CompanyID = c.CompanyID
left outer join @CompanyParamTable cpara on c.CompanyID = cpara.ID 
left outer join @TempBookMarkTable tb on tb.CompanyID = c.CompanyID 
left outer join @TempCategoryTable tc on tc.CompanyID = c.CompanyID 
where (cpara.ID > 0 or @CompanyIDs is null)
and (c.CompanyID = @CompanyID or @CompanyID is null) 
and (c.[CompanyName] like @Name or isnull(@Name,'')='')
and (c.LastTradingDate is null or c.LastTradingDate < @LastTradingDate or @LastTradingDate is null)
and (cf.LastUpdatedDate is null or cf.LastUpdatedDate < @LastFundamentalDate or @LastFundamentalDate is null)
and (tb.CompanyID > 0 or @isBookMarkCategory is null)
and (tc.CompanyID > 0 or @CategoryIDs is null)

select c.*
from Company c
left outer join CompanyFundamental cf on cf.CompanyID = c.CompanyID
left outer join @CompanyParamTable cpara on c.CompanyID = cpara.ID 
left outer join @TempBookMarkTable tb on tb.CompanyID = c.CompanyID 
left outer join @TempCategoryTable tc on tc.CompanyID = c.CompanyID 
where cpara.ID > 0 or @CompanyIDs is null
and (c.CompanyID = @CompanyID or @CompanyID is null) 
and (c.[CompanyName] like @Name or isnull(@Name,'')='')
and (c.LastTradingDate is null or c.LastTradingDate < @LastTradingDate or @LastTradingDate is null)
and (cf.LastUpdatedDate is null or cf.LastUpdatedDate < @LastFundamentalDate or @LastFundamentalDate is null)
and (tb.CompanyID > 0 or @isBookMarkCategory is null)
and (tc.CompanyID > 0 or @CategoryIDs is null)
--{{ORDER_BY_START}}
order by [CompanyName] asc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
