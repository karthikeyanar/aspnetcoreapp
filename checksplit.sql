select c.CompanyName,c.Symbol,mp.FromDate,mph.* from dm_month_period_history mph
join dm_month_period mp on mp.dm_month_period_id = mph.dm_month_period_id
join company c on c.CompanyID = mph.CompanyID
where mp.FromDate = '2018-11-01'
order by mph.Percentage asc
go
select c.CompanyName,c.Symbol,mp.FromDate,mph.* from dm_month_period_history mph
join dm_month_period mp on mp.dm_month_period_id = mph.dm_month_period_id
join company c on c.CompanyID = mph.CompanyID
where mp.FromDate = '2018-11-01'
and c.Symbol = 'KESORAMIND'
order by mph.Percentage desc
go
select c.CompanyName,c.Symbol,cph.* from CompanyPriceHistory cph
join company c on c.CompanyID = cph.CompanyID
where c.Symbol = 'KESORAMIND'
order by cph.Date desc
go
