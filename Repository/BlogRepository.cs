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

    public interface IBlogRepository {
        PaginatedListResult<Blog> List(SearchModel criteria, Paging paging);
    }

    public class BlogRepository : IBlogRepository {

        public PaginatedListResult<Blog> List(SearchModel criteria, Paging paging) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", paging.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", paging.PageIndex);
            if (string.IsNullOrEmpty(criteria.Name) == false) {
                sqlParams += string.Format("set @Name = '{0}';", criteria.Name);
            }
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Blog", "List.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + paging.SortName + " " + paging.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<Blog> list = new PaginatedListResult<Blog>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<Blog>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }
 
    }

}