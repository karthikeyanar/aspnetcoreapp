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

namespace aspnetcoreapp.Repository {

    public interface IPortfolioRepository {
        PaginatedListResult<PortfolioTransactionModel> Get(SearchModel criteria);
        PaginatedListResult<PortfolioTransactionModel> Save(PortfolioTransactionModel model);
        void Delete(int id);
        PaginatedListResult<PortfolioModel> GetInvestments(SearchModel criteria);
    }

    public class PortfolioRepository : IPortfolioRepository {

        public PaginatedListResult<PortfolioTransactionModel> Get(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            if (criteria.id > 0) {
                sqlParams += string.Format("set @ID = {0};", criteria.id);
            }
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Portfolio", "List.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<PortfolioTransactionModel> list = new PaginatedListResult<PortfolioTransactionModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<PortfolioTransactionModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }

        public PaginatedListResult<PortfolioTransactionModel> Save(PortfolioTransactionModel model) {
            string filePath = string.Empty;
            if (model.PortfolioTransactionID <= 0) {
                filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Portfolio", "Insert.sql");
            } else {
                filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Portfolio", "Update.sql");
            }
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            PropertyInfo[] properties = model.GetType().GetProperties();
            SqlParameter sqlp = null;
            List<String> ignoreProperties = new List<string>() { "CompanyName", "TransactionTypeName", "Symbol", "Amount" };
            foreach (var p in properties) {
                if (ignoreProperties.Contains(p.Name) == false) {
                    sqlp = new SqlParameter();
                    sqlp.ParameterName = p.Name;
                    sqlp.Value = p.GetValue(model);
                    sqlParameterCollection.Add(sqlp);
                }
            }
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
            if (model.PortfolioTransactionID <= 0) {
                sql = "SELECT idENT_CURRENT ('PortFolioTransaction') AS Current_Identity;";
                model.PortfolioTransactionID = DataTypeHelper.ToInt32(SqlHelper.ExecuteScaler(sql, new List<SqlParameter>()));
            }
            return this.Get(new SearchModel { id = model.PortfolioTransactionID, SortName = "id" });
        }

        public void Delete(int id) {
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Portfolio", "Delete.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            SqlParameter sqlp = new SqlParameter();
            sqlp.ParameterName = "PortFolioTransactionID";
            sqlp.Value = id;
            sqlParameterCollection.Add(sqlp);
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
        }

        public PaginatedListResult<PortfolioModel> GetInvestments(SearchModel criteria) {
            string sqlParams = string.Empty;
            sqlParams += string.Format("set @PageSize = {0};", criteria.PageSize);
            sqlParams += string.Format("set @PageIndex = {0};", criteria.PageIndex);
            string filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Portfolio", "Investment.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            string orderBy = " order by " + criteria.SortName + " " + criteria.SortOrder;
            sql = Helper.ReplaceOrderBy(sql, orderBy);
            sql = Helper.ReplaceParams(sql, sqlParams);
            //sql = sql.Replace("\r\n"," ");
            PaginatedListResult<PortfolioModel> list = new PaginatedListResult<PortfolioModel>();
            int totalRows = 0;
            list.rows = SqlHelper.GetList<PortfolioModel>(sql, ref totalRows);
            list.total = totalRows;
            return list;
        }

    }

}