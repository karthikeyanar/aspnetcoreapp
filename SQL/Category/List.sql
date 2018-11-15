DECLARE @PageSize INT = 10, @PageIndex INT = 1;
DECLARE @Name varchar(max);
DECLARE @LastTradingDate date;
DECLARE @CategoryID int;
--set @LastTradingDate = '2018-11-06';

--{{PARAMS}}
if isnull(@Name,'')!=''
	begin
		set @Name = '%' + RTRIM(@Name) + '%';  
	end

--START SQL
select count(*) as [Count] from Category c
where (c.CategoryID = @CategoryID or @CategoryID is null) and (c.[CategoryName] like @Name or isnull(@Name,'')='')

select * from Category c
where (c.CategoryID = @CategoryID or @CategoryID is null) and (c.[CategoryName] like @Name or isnull(@Name,'')='')
--{{ORDER_BY_START}}
order by [CategoryName] asc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
