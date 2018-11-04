using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Repository {

    public interface IReportRepository {
        PaginatedListResult<MonthlyModel> GetMonthly(SearchModel criteria);
    }

    public class ReportRepository : IReportRepository {

        public PaginatedListResult<MonthlyModel> GetMonthly(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            sqlParams += string.Format("set @isBookMarkCategory = {0};", (criteria.IsBookMarkCategory ?? false) == true ? 1 : 0);
            sqlParams += string.Format("set @fromDate = '{0}';", (criteria.FromDate ?? Helper.MinDateTime).ToString("MM/dd/yyyy"));
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Report", "Monthly.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<MonthlyModel> list = new PaginatedListResult<MonthlyModel>();
            int totalRows = 0;
            decimal? average = 0;
            list.rows = SqlHelper.GetList<MonthlyModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }
 
    }

}