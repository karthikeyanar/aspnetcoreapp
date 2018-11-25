
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Reflection;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using aspnetcoreapp.Repository;
using CsvHelper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CompanyController : ControllerBase
    {
        private readonly IConfiguration configuration;
        public CompanyController(IConfiguration config)
        {
            configuration = config;
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<CompanyModel>> List([FromQuery] SearchModel criteria)
        {
            ICompanyRepository repository = new CompanyRepository();
            return repository.Get(criteria);
        }

        [HttpPost]
        public ActionResult Save(CompanyModel model)
        {
            ICompanyRepository repository = new CompanyRepository();
            return Ok(repository.Save(model));
        }

        [HttpGet]
        public ActionResult Delete([FromQuery] int id)
        {
            ICompanyRepository repository = new CompanyRepository();
            repository.Delete(id);
            return Ok();
        }

        [HttpPost]
        public ActionResult UpdateScreenerCSV(SearchModel model)
        {
            CompanyFundamental cf = new CompanyFundamental();
            string csvContent = model.csv;
            string[] rows = csvContent.Split(("|").ToCharArray());
            foreach (string row in rows)
            {
                string[] cells = row.Split(("~").ToCharArray());
                if (cells[0].Contains("CompanyID"))
                {
                    cf.CompanyID = DataTypeHelper.ToInt32(cells[1]);
                }
                else if (cells[0].Contains("Market Cap"))
                {
                    cf.MarketCapital = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("52 weeks High / Low"))
                {
                    cf.Week52High = DataTypeHelper.ToDecimal(cells[1]);
                    cf.Week52Low = DataTypeHelper.ToDecimal(cells[2]);
                }
                else if (cells[0].Contains("Book Value"))
                {
                    cf.BookValue = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Stock P/E"))
                {
                    cf.StockPE = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Dividend Yield"))
                {
                    cf.DividendYield = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("ROCE"))
                {
                    cf.ROCE = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("ROE"))
                {
                    cf.ROE = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Sales Growth (3Yrs)"))
                {
                    cf.SalesGrowth_3_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Face Value"))
                {
                    cf.FaceValue = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Debt to equity"))
                {
                    cf.DE = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("PEG Ratio"))
                {
                    cf.PEG = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("EPS"))
                {
                    cf.EPS = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Interest"))
                {
                    cf.Interest = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Profit growth:"))
                {
                    cf.ProfitGrowth = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Profit growth 3Years"))
                {
                    cf.ProfitGrowth_3_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Promoter holding"))
                {
                    cf.PromoterHolding = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Sales growth:"))
                {
                    cf.SalesGrowth = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Average return on equity 3Years"))
                {
                    cf.ROE_3_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Average return on capital employed 3Years"))
                {
                    cf.ROCE_3_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("G Factor"))
                {
                    cf.GFactor = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Piotroski score"))
                {
                    cf.PiotroskiScore = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Price to Sales"))
                {
                    cf.PS = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Price to book value"))
                {
                    cf.PB = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Sales growth 5Years"))
                {
                    cf.SalesGrowth_5_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Sales growth 7Years"))
                {
                    cf.SalesGrowth_7_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Sales growth 10Years"))
                {
                    cf.SalesGrowth_10_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Profit growth 5Years"))
                {
                    cf.ProfitGrowth_5_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Profit growth 7Years"))
                {
                    cf.ProfitGrowth_7_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Profit growth 10Years"))
                {
                    cf.ProfitGrowth_10_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Current Price"))
                {
                    cf.CurrentPrice = DataTypeHelper.ToDecimal(cells[1]);
                }
            }
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "CompanyFundamental", "Save.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            PropertyInfo[] properties = cf.GetType().GetProperties();
            SqlParameter sqlp = null;
            List<String> ignoreProperties = new List<string>() { };
            foreach (var p in properties)
            {
                if (ignoreProperties.Contains(p.Name) == false)
                {
                    sqlp = new SqlParameter();
                    sqlp.ParameterName = p.Name;
                    sqlp.Value = p.GetValue(cf);
                    if(DataTypeHelper.ToDecimal(Convert.ToString(sqlp.Value))<=0){
                        sqlp.Value = 0;
                    }
                    sqlParameterCollection.Add(sqlp);
                }
            }
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
            return Ok();
        }

        [HttpPost]
        public ActionResult UpdateCSV(SearchModel model)
        {
            string csvContent = model.csv.Replace("|", Environment.NewLine);
            string connectionString = Helper.ConnectionString;
            List<string> symbols = new List<string>();
            SqlParameter sqlp = null;
            int i = 0;
            i += 1;
            CsvReader csv = null;

            List<InvestmentPrice> priceHistory = new List<InvestmentPrice>();
            using (TextReader reader = new StringReader(csvContent))
            {
                csv = new CsvReader(reader);
                while (csv.Read())
                {
                    int companyID = DataTypeHelper.ToInt32(csv.GetField<string>("CompanyID"));
                    DateTime date = DataTypeHelper.ToDateTime(csv.GetField<string>("Date"));
                    decimal open = DataTypeHelper.ToDecimal(csv.GetField<string>("Open Price"));
                    decimal high = DataTypeHelper.ToDecimal(csv.GetField<string>("High Price"));
                    decimal low = DataTypeHelper.ToDecimal(csv.GetField<string>("Low Price"));
                    decimal close = DataTypeHelper.ToDecimal(csv.GetField<string>("Close Price"));
                    decimal change = DataTypeHelper.ToDecimal(csv.GetField<string>("Change"));
                    decimal prevCloseValue = close - (close * change) / 100;
                    DateTime dt = DataTypeHelper.ToDateTime(date);
                    if (companyID > 0)
                    {
                        priceHistory.Add(new InvestmentPrice
                        {
                            Close = close,
                            CompanyID = companyID,
                            Date = date,
                            High = high,
                            Low = low,
                            Open = open,
                            PrevClose = prevCloseValue
                        });
                    }
                }
            }

            priceHistory = (from q in priceHistory
                            orderby q.Date ascending
                            select q).ToList();

            foreach (var price in priceHistory)
            {
                string sql = "";
                sql = "INSERT INTO [dbo].[CompanyPriceHistory]" + Environment.NewLine +
               " ([CompanyID]" + Environment.NewLine +
               ",[Date]" + Environment.NewLine +
               ",[Open]" + Environment.NewLine +
               ",[Low]" + Environment.NewLine +
               ",[High]" + Environment.NewLine +
               ",[Close]" + Environment.NewLine +
               ",[PrevClose]" + Environment.NewLine +
               " ) VALUES (" + Environment.NewLine +
               "@companyID" + Environment.NewLine +
               ",@date" + Environment.NewLine +
               ",@open" + Environment.NewLine +
               ",@low" + Environment.NewLine +
               ",@high" + Environment.NewLine +
               ",@close" + Environment.NewLine +
               ",@prevclose" + Environment.NewLine +
               ")";
                //Console.WriteLine("dt=" + dt.ToString("MM/dd/yyyy"));
                try
                {
                    using (SqlConnection connection = new SqlConnection(
                       connectionString))
                    {
                        SqlCommand command = new SqlCommand(sql, connection);
                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "companyID";
                        sqlp.Value = price.CompanyID;
                        command.Parameters.Add(sqlp);

                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "date";
                        sqlp.Value = price.Date;//.ToString("yyyy-MM-dd");
                        command.Parameters.Add(sqlp);

                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "open";
                        sqlp.Value = price.Open;
                        command.Parameters.Add(sqlp);

                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "low";
                        sqlp.Value = price.Low;
                        command.Parameters.Add(sqlp);

                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "high";
                        sqlp.Value = price.High;
                        command.Parameters.Add(sqlp);

                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "close";
                        sqlp.Value = price.Close;
                        command.Parameters.Add(sqlp);

                        sqlp = new SqlParameter();
                        sqlp.ParameterName = "prevclose";
                        sqlp.Value = price.PrevClose;
                        command.Parameters.Add(sqlp);

                        command.Connection.Open();
                        command.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    if (ex.Message.ToString().Contains("PRIMARY KEY") == false)
                    {
                        return BadRequest(ex.Message);
                    }
                }
            }
            return Ok();
        }

    }

}