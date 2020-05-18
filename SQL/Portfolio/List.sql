DECLARE @PageSize INT = 10, @PageIndex INT = 1;
DECLARE @CompanyIDs varchar(max);
declare @ID int;

--{{PARAMS}} 

DECLARE @CompanyParamTable TABLE
(
ID int
)
DECLARE @SQL varchar(max);

SELECT @SQL = 'SELECT ''' + REPLACE (@CompanyIDs,',',''' UNION SELECT ''') + ''''
INSERT INTO @CompanyParamTable (ID) EXEC (@SQL)

--START SQL 
select count(*) as [Count]
from PortfolioTransaction p
join Company c on c.CompanyID = p.CompanyID
left outer join @CompanyParamTable cpara on c.CompanyID = cpara.ID 
where (p.PortfolioTransactionID = @ID or @ID is null)
and (cpara.ID > 0 or @CompanyIDs is null)

select p.*,c.CompanyName,c.Symbol,tt.[Name] as TransactionTypeName,(p.Quantity * p.CostPerShare) as Amount from PortfolioTransaction p
join Company c on c.CompanyID = p.CompanyID
left outer join @CompanyParamTable cpara on c.CompanyID = cpara.ID 
left outer join TransactionType tt on tt.TransactionTypeID = p.TransactionTypeID
where (p.PortfolioTransactionID = @ID or @ID is null)
and (cpara.ID > 0 or @CompanyIDs is null)
--{{ORDER_BY_START}}
order by p.TransactionDate desc
--{{ORDER_BY_END}}
OFFSET (@PageIndex-1)*@PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
