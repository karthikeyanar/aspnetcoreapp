select his.CompanyID,his.[Date],(select isnull(count(*),0) from CompanyPriceHistory cph where cph.CompanyID = his.CompanyID and cph.[Date] = his.[Date] and cph.[PrevClose] > cph.[Close]) as Advance  from CompanyPriceHistory his
where his.[Date] >= '2018/11/07'
order by his.[Date] desc