select CompanyName as label,CompanyID as id from [Company] where isnull(@Term,'') = '' or (CompanyName like @Term or Symbol like @Term)
order by [CompanyName] asc
OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY

