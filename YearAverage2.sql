select yp.Year,his.* from dm_year_period_history his
join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id 
where his.CompanyID = 36
go

select AVG(Percentage) from dm_year_period_history his
join dm_year_period yp on yp.dm_year_period_id = his.dm_year_period_id 
where his.CompanyID = 36
go