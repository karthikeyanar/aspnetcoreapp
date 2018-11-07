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

    public interface ICompanyRepository {
        PaginatedListResult<CompanyModel> Get(SearchModel criteria);
    }

    public class CompanyRepository : ICompanyRepository {

        public PaginatedListResult<CompanyModel> Get(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            //sqlParams += string.Format("set @LastTradingDate = '{0}';", (criteria.LastTradingDate ?? Helper.MinDateTime).ToString("yyyy-MM-dd"));
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Company", "List.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<CompanyModel> list = new PaginatedListResult<CompanyModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<CompanyModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }
 
    }

}