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
        PaginatedListResult<DailyModel> GetDaily(SearchModel criteria);
        PaginatedListResult<CAGRModel> GetCAGR(SearchModel criteria);
    }

    public class ReportRepository : IReportRepository {

        public PaginatedListResult<MonthlyModel> GetMonthly(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            if(criteria.IsBookMarkCategory == true) {
                sqlParams += string.Format("set @isBookMarkCategory = {0};", (criteria.IsBookMarkCategory ?? false) == true ? 1 : 0);
            }
            if(criteria.IsBookMark == true) {
                sqlParams += string.Format("set @isBookMark = {0};", (criteria.IsBookMark ?? false) == true ? 1 : 0);
            }
            sqlParams += string.Format("set @fromDate = '{0}';", (criteria.FromDate ?? Helper.MinDateTime).ToString("MM/dd/yyyy"));
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Report", "Monthly.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<MonthlyModel> list = new PaginatedListResult<MonthlyModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<MonthlyModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }

        public PaginatedListResult<DailyModel> GetDaily(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            if(criteria.IsBookMarkCategory == true) {
                sqlParams += string.Format("set @isBookMarkCategory = {0};", (criteria.IsBookMarkCategory ?? false) == true ? 1 : 0);
            }
             if(criteria.IsBookMark == true) {
                sqlParams += string.Format("set @isBookMark = {0};", (criteria.IsBookMark ?? false) == true ? 1 : 0);
            }
            sqlParams += string.Format("set @fromDate = '{0}';", (criteria.FromDate ?? Helper.MinDateTime).ToString("yyyy-MM-dd"));
            sqlParams += string.Format("set @toDate = '{0}';", (criteria.ToDate ?? Helper.MinDateTime).ToString("yyyy-MM-dd"));
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Report", "Daily.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<DailyModel> list = new PaginatedListResult<DailyModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<DailyModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }

        public PaginatedListResult<CAGRModel> GetCAGR(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            if(criteria.IsBookMarkCategory == true) {
                sqlParams += string.Format("set @isBookMarkCategory = {0};", (criteria.IsBookMarkCategory ?? false) == true ? 1 : 0);
            }
             if(criteria.IsBookMark == true) {
                sqlParams += string.Format("set @isBookMark = {0};", (criteria.IsBookMark ?? false) == true ? 1 : 0);
            }
            if (string.IsNullOrEmpty(criteria.CategoryIDs) == false)
            {
                sqlParams += string.Format("set @CategoryIDs = '{0}';", criteria.CategoryIDs);
            }
            sqlParams += string.Format("set @fromDate = '{0}';", (criteria.FromDate ?? Helper.MinDateTime).ToString("yyyy-MM-dd"));
            sqlParams += string.Format("set @toDate = '{0}';", (criteria.ToDate ?? Helper.MinDateTime).ToString("yyyy-MM-dd"));
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Report", "CAGR.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<CAGRModel> list = new PaginatedListResult<CAGRModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<CAGRModel>(sql);
            list.total = totalRows;
            return list;
        }
 
    }

}