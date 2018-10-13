DECLARE @PageSize INT = 10, @PageIndex INT = 1;
DECLARE @Name varchar(max);
--{{PARAMS}}
if isnull(@Name,'')!=''
	begin
		set @Name = '%' + RTRIM(@Name) + '%';  
	end

--START SQL
select count(*) as [Count] from SecurityType
where [Name] like @Name or isnull(@Name,'')=''

select * from SecurityType
where [Name] like @Name or isnull(@Name,'')=''
--{{ORDER_BY_START}}
order by [SecurityTypeID] asc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
