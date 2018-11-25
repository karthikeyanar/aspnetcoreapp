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

    public interface ICompanyRepository
    {
        PaginatedListResult<CompanyModel> Get(SearchModel criteria);
        PaginatedListResult<CompanyModel> Save(CompanyModel model);
        void Delete(int id);
        List<Select2List> FindCompanies(string term);
    }

    public class CompanyRepository : ICompanyRepository
    {

        public PaginatedListResult<CompanyModel> Get(SearchModel criteria)
        {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            if (criteria.CompanyID > 0)
            {
                sqlParams += string.Format("set @CompanyID = {0};", criteria.CompanyID);
            }
            if (string.IsNullOrEmpty(criteria.CompanyIDs) == false)
            {
                sqlParams += string.Format("set @CompanyIDs = '{0}';", criteria.CompanyIDs);
            }
            if (string.IsNullOrEmpty(criteria.CategoryIDs) == false)
            {
                sqlParams += string.Format("set @CategoryIDs = '{0}';", criteria.CategoryIDs);
            }
            if ((criteria.IsBookMarkCategory ?? false) == true)
            {
                sqlParams += string.Format("set @isBookMarkCategory = 1;");
            }
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

        public PaginatedListResult<CompanyModel> Save(CompanyModel model)
        {
            string filePath = string.Empty;
            if (model.CompanyID <= 0)
            {
                filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Company", "Insert.sql");
            }
            else
            {
                filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Company", "Update.sql");
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
            if (model.CompanyID <= 0)
            {
                sql = "SELECT IDENT_CURRENT ('Company') AS Current_Identity;";
                model.CompanyID = DataTypeHelper.ToInt32(SqlHelper.ExecuteScaler(sql, new List<SqlParameter>()));
            }
            return this.Get(new SearchModel { CompanyID = model.CompanyID, SortName = "CompanyID" });
        }

        public void Delete(int id)
        {
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Company", "Delete.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            SqlParameter sqlp = new SqlParameter();
            sqlp.ParameterName = "CompanyID";
            sqlp.Value = id;
            sqlParameterCollection.Add(sqlp);
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
        }

        public List<Select2List> FindCompanies(string term)
        {
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Company", "Select2.sql");
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