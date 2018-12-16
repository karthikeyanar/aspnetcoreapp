select c.CompanyName,c.Symbol,mp.FromDate,mp.ToDate,mph.* from dm_month_period_history mph
join Company c on mph.CompanyID = c.CompanyID 
join dm_month_period mp on mp.dm_month_period_id = mph.dm_month_period_id 
--where c.Symbol = 'HUDCO'
order by mph.Percentage desc -- mp.FromDate asc
go
select cph.* from CompanyPriceHistory cph
join Company c on cph.CompanyID = c.CompanyID 
where c.Symbol = 'BEARDSELL'
--and cph.[Date] >= '2016-01-01'
go

 --exec [dbo].[PROC_dm_equity_period_history] 677;