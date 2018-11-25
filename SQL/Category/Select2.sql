select CategoryName as label,CategoryID as id from [Category] where isnull(@Term,'') = '' or (CategoryName like @Term)
order by [CategoryName] asc
OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY