using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Repository
{

    public interface ICategoryRepository
    {
        PaginatedListResult<CategoryModel> Get(SearchModel criteria);
        PaginatedListResult<CategoryModel> Save(CategoryModel model);
        void Delete(int id);
        List<Select2List> FindCategories(string term);
    }

    public class CategoryRepository : ICategoryRepository
    {

        public PaginatedListResult<CategoryModel> Get(SearchModel criteria)
        {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            if (criteria.CategoryID > 0)
            {
                sqlParams += string.Format("set @CategoryID = {0};", criteria.CategoryID);
            }
            if ((criteria.IsBookMark ?? false) == true)
            {
                sqlParams += string.Format("set @IsBookMark = 1;");
            }
            if ((criteria.IsArchive ?? false) == true)
            {
                sqlParams += string.Format("set @IsArchive = 1;");
            }
            //sqlParams += string.Format("set @LastTradingDate = '{0}';", (criteria.LastTradingDate ?? Helper.MinDateTime).ToString("yyyy-MM-dd"));
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Category", "List.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<CategoryModel> list = new PaginatedListResult<CategoryModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<CategoryModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }

        public PaginatedListResult<CategoryModel> Save(CategoryModel model)
        {
            string filePath = string.Empty;
            if (model.CategoryID <= 0)
            {
                filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Category", "Insert.sql");
            }
            else
            {
                filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Category", "Update.sql");
            }
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            PropertyInfo[] properties = model.GetType().GetProperties();
            SqlParameter sqlp = null;
            List<String> ignoreProperties = new List<string>() { "LastTradingDate" };
            foreach (var p in properties)
            {
                if (ignoreProperties.Contains(p.Name) == false)
                {
                    sqlp = new SqlParameter();
                    sqlp.ParameterName = p.Name;
                    sqlp.Value = p.GetValue(model);
                    sqlParameterCollection.Add(sqlp);
                }
            }
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
            if (model.CategoryID <= 0)
            {
                sql = "SELECT IDENT_CURRENT ('Category') AS Current_Identity;";
                model.CategoryID = DataTypeHelper.ToInt32(SqlHelper.ExecuteScaler(sql, new List<SqlParameter>()));
            }
            return this.Get(new SearchModel { CategoryID = model.CategoryID, SortName = "CategoryID" });
        }

        public void Delete(int id)
        {
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Category", "Delete.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            SqlParameter sqlp = new SqlParameter();
            sqlp.ParameterName = "CategoryID";
            sqlp.Value = id;
            sqlParameterCollection.Add(sqlp);
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
        }

        public List<Select2List> FindCategories(string term)
        {
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Category", "Select2.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            SqlParameter sqlp = new SqlParameter();
            sqlp.ParameterName = "Term";
            sqlp.Value = (string.IsNullOrEmpty(term) == false ? "%" + term + "%" : "");
            sqlParameterCollection.Add(sqlp);
            return SqlHelper.GetList<Select2List>(sql, sqlParameterCollection);
        }

    }

}