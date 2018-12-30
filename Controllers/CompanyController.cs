
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

        [HttpGet]
        public ActionResult<PaginatedListResult<LongTermModel>> LongTerm([FromQuery] SearchModel criteria)
        {

            ICompanyRepository repository = new CompanyRepository();
            return repository.LongTerm(criteria);
        }

        [HttpGet]
        public ActionResult<List<CompanyFundamentalModel>> FindCompanyFundamental([FromQuery] SearchModel criteria)
        {
            ICompanyRepository repository = new CompanyRepository();
            return repository.FindCompanyFundamental((criteria.id ?? 0));
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

        [HttpGet]
        public ActionResult DeletePriceHistory([FromQuery] int id)
        {
            ICompanyRepository repository = new CompanyRepository();
            repository.DeletePriceHistory(id);
            return Ok();
        }

        [HttpGet]
        public ActionResult FindCompanies([FromQuery] string term)
        {
            ICompanyRepository repository = new CompanyRepository();
            return Ok(repository.FindCompanies(term));
        }

        [HttpGet]
        public ActionResult SplitCheck([FromQuery] SearchModel criteria)
        {
            ICompanyRepository repository = new CompanyRepository();
            return Ok(repository.GetSplitCheck(criteria));
        }

        [HttpPost]
        public ActionResult CreateSplit(SplitCheckModel model)
        {
            string filePath = string.Empty;
            filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Split", "Insert.sql");
            string sql = System.IO.File.ReadAllText(filePath);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            PropertyInfo[] properties = model.GetType().GetProperties();
            SqlParameter sqlp = null;
            List<String> ignoreProperties = new List<string>() { "CompanyName", "Symbol", "Percentage", "Open", "PrevClose" };
            foreach (var p in properties)
            {
                if (ignoreProperties.Contains(p.Name) == false)
                {
                    sqlp = new SqlParameter();
                    sqlp.ParameterName = p.Name;
                    if (p.Name == "SplitDate")
                    {
                        sqlp.Value = model.SplitDate.Value.ToString("yyyy-MM-dd");
                    }
                    else
                    {
                        sqlp.Value = p.GetValue(model);
                    }
                    sqlParameterCollection.Add(sqlp);
                }
            }
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
            return Ok();
        }

        [HttpPost]
        public ActionResult UpdateBookMark(CompanyModel model)
        {
            string sql = string.Format("update company set isbookmark={0} where companyid={1}", (model.IsBookMark == true ? 1 : 0), model.CompanyID);
            List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
            return Ok();
        }

        [HttpPost]
        public ActionResult UpdateScreenerCSV(SearchModel model)
        {
            CompanyFundamentalModel cf = new CompanyFundamentalModel();
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
                else if (cells[0].Contains("Average return on equity 3Years"))
                {
                    cf.ROE_3_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Average return on equity 5Years"))
                {
                    cf.ROE_5_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Average return on equity 7Years"))
                {
                    cf.ROE_7_Years = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Average return on equity 10Years"))
                {
                    cf.ROE_10_Years = DataTypeHelper.ToDecimal(cells[1]);
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
                else if (cells[0].Contains("EPS:"))
                {
                    cf.EPS_Year_1 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("EPS last year"))
                {
                    cf.EPS_Year_2 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("EPS preceding year"))
                {
                    cf.EPS_Year_3 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("EPS latest quarter"))
                {
                    cf.EPS_Quater_1 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("EPS preceding quarter"))
                {
                    cf.EPS_Quater_2 = DataTypeHelper.ToDecimal(cells[1]);
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
                else if (cells[0].Contains("Sales Growth (3Yrs)"))
                {
                    cf.SalesGrowth_3_Years = DataTypeHelper.ToDecimal(cells[1]);
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
                else if (cells[0].Contains("Net Profit latest quarter"))
                {
                    cf.NetProfit_Quater_1 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Net Profit preceding quarter"))
                {
                    cf.NetProfit_Quater_2 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Net profit 2quarters back"))
                {
                    cf.NetProfit_Quater_3 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Net profit 3quarters back"))
                {
                    cf.NetProfit_Quater_4 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Net profit:"))
                {
                    cf.NetProfit_Year_1 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Net Profit last year"))
                {
                    cf.NetProfit_Year_2 = DataTypeHelper.ToDecimal(cells[1]);
                }
                else if (cells[0].Contains("Net Profit preceding year"))
                {
                    cf.NetProfit_Year_3 = DataTypeHelper.ToDecimal(cells[1]);
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
                    if (DataTypeHelper.ToDecimal(Convert.ToString(sqlp.Value)) == 0)
                    {
                        sqlp.Value = 0;
                    }
                    sqlParameterCollection.Add(sqlp);
                }
            }
            SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
            return Ok();
        }

        [HttpPost]
        public ActionResult UpdateMoneyControlCSV(SearchModel model)
        {
            ICompanyRepository repository = new CompanyRepository();
            List<ShareHoldingTypeModel> shareHoldingTypes = repository.GetShareHoldingTypes();
            string csvContent = model.csv;
            string[] rows = csvContent.Split((";").ToCharArray());
            foreach (string row in rows)
            {
                CompanyShareHoldingModel holding = null;
                string[] cells = row.Split(("|").ToCharArray());
                if (cells.Length >= 3)
                {
                    ShareHoldingTypeModel type = (from q in shareHoldingTypes
                                                  where q.ShareHoldingTypeName == cells[1]
                                                  select q).FirstOrDefault();
                    if (type == null)
                    {
                        Helper.Log("Holding type does not exist name=" + cells[1], "MoneyControlCSV");
                    }
                    if (type != null)
                    {
                        holding = new CompanyShareHoldingModel
                        {
                            CompanyID = DataTypeHelper.ToInt32(cells[0]),
                            ShareHoldingTypeID = type.ShareHoldingTypeID,
                            Total = DataTypeHelper.ToInt32(cells[2]),
                            TotalShares = DataTypeHelper.ToInt32(cells[3])
                        };

                        string filePath = string.Empty;
                        filePath = System.IO.Path.Combine(Helper.RootPath, "SQL", "Company", "CompanyShareHoldingSave.sql");
                        string sql = System.IO.File.ReadAllText(filePath);
                        List<SqlParameter> sqlParameterCollection = new List<SqlParameter>();
                        PropertyInfo[] properties = holding.GetType().GetProperties();
                        SqlParameter sqlp = null;
                        List<String> ignoreProperties = new List<string>() { };
                        foreach (var p in properties)
                        {
                            if (ignoreProperties.Contains(p.Name) == false)
                            {
                                sqlp = new SqlParameter();
                                sqlp.ParameterName = p.Name;
                                sqlp.Value = p.GetValue(holding);
                                if (DataTypeHelper.ToDecimal(Convert.ToString(sqlp.Value)) == 0)
                                {
                                    sqlp.Value = 0;
                                }
                                sqlParameterCollection.Add(sqlp);
                            }
                        }
                        SqlHelper.ExecuteNonQuery(sql, sqlParameterCollection);
                    }
                }
            }
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

            int companyID = 0;

            List<InvestmentPrice> priceHistory = new List<InvestmentPrice>();
            using (TextReader reader = new StringReader(csvContent))
            {
                csv = new CsvReader(reader);
                while (csv.Read())
                {
                    companyID = DataTypeHelper.ToInt32(csv.GetField<string>("CompanyID"));
                    DateTime date = DataTypeHelper.ToDateTime(csv.GetField<string>("Date"));
                    decimal open = DataTypeHelper.ToDecimal(csv.GetField<string>("Open Price"));
                    decimal high = DataTypeHelper.ToDecimal(csv.GetField<string>("High Price"));
                    decimal low = DataTypeHelper.ToDecimal(csv.GetField<string>("Low Price"));
                    //decimal close = DataTypeHelper.ToDecimal(csv.GetField<string>("Close Price"));
                    decimal change = DataTypeHelper.ToDecimal(csv.GetField<string>("Change"));
                    decimal close = 0;
                    decimal p = (open * change) / 100;
                    if (change > 0)
                        close = open + p;
                    else
                        close = open - (p * -1);

                    decimal prevCloseValue = 0;
                    p = (close * change) / 100;
                    if (change > 0)
                        prevCloseValue = close + p;
                    else
                        prevCloseValue = close - (p * -1);

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
                ",[OriginalOpen]" + Environment.NewLine +
                ",[OriginalLow]" + Environment.NewLine +
                ",[OriginalHigh]" + Environment.NewLine +
                ",[OriginalClose]" + Environment.NewLine +
                ",[OriginalPrevClose]" + Environment.NewLine +
               " ) VALUES (" + Environment.NewLine +
               "@companyID" + Environment.NewLine +
               ",@date" + Environment.NewLine +
               ",@open" + Environment.NewLine +
               ",@low" + Environment.NewLine +
               ",@high" + Environment.NewLine +
               ",@close" + Environment.NewLine +
               ",@prevclose" + Environment.NewLine +
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
            if (companyID > 0)
            {
                ICompanyRepository repository = new CompanyRepository();
                //repository.CreateEquitySplit(companyID);
                repository.UpdateCompanyHistory(companyID);
            }
            return Ok();
        }

        [HttpPost]
        public ActionResult UpdateNSECSV(SearchModel model)
        {
            List<CompanyModel> companies = new List<CompanyModel>();
            string connectionString = Helper.ConnectionString;
            string sql = "select companyid,symbol from company";
            int companyID;
            string symbol;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sql, connection);
                command.Connection.Open();
                SqlDataReader dr = command.ExecuteReader();
                while (dr.Read())
                {
                    companyID = (int)dr["companyid"];
                    symbol = dr["symbol"].ToString();
                    companies.Add(new CompanyModel
                    {
                        CompanyID = companyID,
                        Symbol = symbol
                    });
                }
                dr.Close();
            }

            string csvContent = model.csv.Replace(":", Environment.NewLine);

            List<string> symbols = new List<string>();
            SqlParameter sqlp = null;
            int i = 0;
            i += 1;
            CsvReader csv = null;

            companyID = 0;

            List<OldSymbol> oldSymbolList = new List<OldSymbol> {
                new OldSymbol { old_symbol = "PFRL", new_symbol = "ABFRL" },
                new OldSymbol { old_symbol = "SKSMICRO", new_symbol = "BHARATFIN" },
                new OldSymbol { old_symbol = "ADI", new_symbol = "FAIRCHEM" },
                new OldSymbol { old_symbol = "FCEL", new_symbol = "FCONSUMER" },
                new OldSymbol { old_symbol = "FRL", new_symbol = "FEL" },
                new OldSymbol { old_symbol = "HCIL", new_symbol = "HSCL" },
                new OldSymbol { old_symbol = "HITACHIHOM", new_symbol = "JCHAC" },
                new OldSymbol { old_symbol = "MAX", new_symbol = "MFSL" },
                new OldSymbol { old_symbol = "GULFCORP", new_symbol = "GOCLCORP" },
                new OldSymbol { old_symbol = "IBSEC", new_symbol = "IBVENTURES" },
                new OldSymbol { old_symbol = "VIKASGLOB", new_symbol = "VIKASECO" },
                new OldSymbol { old_symbol = "FINANTECH", new_symbol = "63MOONS" },
                new OldSymbol { old_symbol = "CROMPGREAV", new_symbol = "CGPOWER" },
                new OldSymbol { old_symbol = "FEDDERLOYD", new_symbol = "FEDDERELEC" },
                new OldSymbol { old_symbol = "GEOJITBNPP", new_symbol = "GEOJITFSL" },
                new OldSymbol { old_symbol = "HITECHPLAS", new_symbol = "HITECHCORP" },
                new OldSymbol { old_symbol = "LLOYDELENG", new_symbol = "LEEL" },
                new OldSymbol { old_symbol = "NAGAAGRI", new_symbol = "NACLIND" },
                new OldSymbol { old_symbol = "SUJANATWR", new_symbol = "NTL" },
                new OldSymbol { old_symbol = "VIDHIDYE", new_symbol = "VIDHIING" },
                new OldSymbol { old_symbol = "STOREONE", new_symbol = "SORILINFRA" },
                new OldSymbol { old_symbol = "ABSHEKINDS", new_symbol = "TRIDENT" },
                new OldSymbol { old_symbol = "ARVINDMILL", new_symbol = "ARVIND" },
                new OldSymbol { old_symbol = "BAJAJAUTO", new_symbol = "BAJAJHLDNG" },
                new OldSymbol { old_symbol = "BAJAUTOFIN", new_symbol = "BAJFINANCE" },
                new OldSymbol { old_symbol = "BIRLAJUTE", new_symbol = "BIRLACORPN" },
                new OldSymbol { old_symbol = "BOC", new_symbol = "LINDEINDIA" },
                new OldSymbol { old_symbol = "CHOLADBS", new_symbol = "CHOLAFIN" },
                new OldSymbol { old_symbol = "DALMIABEL", new_symbol = "DALMIABHA" },
                new OldSymbol { old_symbol = "DCMSRMCONS", new_symbol = "DCMSHRIRAM" },
                new OldSymbol { old_symbol = "DEWANHOUS", new_symbol = "DHFL" },
                new OldSymbol { old_symbol = "FCH", new_symbol = "CAPF" },
                new OldSymbol { old_symbol = "FVIL", new_symbol = "FCONSUMER" },
                new OldSymbol { old_symbol = "GUJAMBCEM", new_symbol = "AMBUJACEM" },
                new OldSymbol { old_symbol = "GWALCHEM", new_symbol = "GEECEE" },
                new OldSymbol { old_symbol = "HEROHONDA", new_symbol = "HEROMOTOCO" },
                new OldSymbol { old_symbol = "HINDALC0", new_symbol = "HINDALCO" },
                new OldSymbol { old_symbol = "HINDLEVER", new_symbol = "HINDUNILVR" },
                new OldSymbol { old_symbol = "HINDSANIT", new_symbol = "HSIL" },
                new OldSymbol { old_symbol = "IBPOW", new_symbol = "RTNPOWER" },
                new OldSymbol { old_symbol = "ICI", new_symbol = "AKZOINDIA" },
                new OldSymbol { old_symbol = "ILFSTRANS", new_symbol = "IL&FSTRANS" },
                new OldSymbol { old_symbol = "JSTAINLESS", new_symbol = "JSL" },
                new OldSymbol { old_symbol = "MADRASCEM", new_symbol = "RAMCOCEM" },
                new OldSymbol { old_symbol = "MICO", new_symbol = "BOSCHLTD" },
                new OldSymbol { old_symbol = "MYSORECEM", new_symbol = "HEIDELBERG" },
                new OldSymbol { old_symbol = "NAGARCONST", new_symbol = "NCC" },
                new OldSymbol { old_symbol = "NEYVELILIG", new_symbol = "NLCINDIA" },
                new OldSymbol { old_symbol = "OBEROIREAL", new_symbol = "OBEROIRLTY" },
                new OldSymbol { old_symbol = "PANTALOONR", new_symbol = "FEL" },
                new OldSymbol { old_symbol = "RAINCOM", new_symbol = "RAIN" },
                new OldSymbol { old_symbol = "REL", new_symbol = "RELINFRA" },
                new OldSymbol { old_symbol = "SESAGOA", new_symbol = "VEDL" },
                new OldSymbol { old_symbol = "SOLAREX", new_symbol = "SOLARINDS" },
                new OldSymbol { old_symbol = "SPLLTD", new_symbol = "SOMANYCERA" },
                new OldSymbol { old_symbol = "SREINTFIN", new_symbol = "SREINFRA" },
                new OldSymbol { old_symbol = "SSLT", new_symbol = "VEDL" },
                new OldSymbol { old_symbol = "SWARAJMAZD", new_symbol = "SMLISUZU" },
                new OldSymbol { old_symbol = "TATATEA", new_symbol = "TATAGLOBAL" },
                new OldSymbol { old_symbol = "UNIPHOS", new_symbol = "UPL" },
                new OldSymbol { old_symbol = "VISHALRET", new_symbol = "V2RETAIL" },
                new OldSymbol { old_symbol = "WABCO-TVS", new_symbol = "WABCOINDIA" },
                new OldSymbol { old_symbol = "WELGUJ", new_symbol = "WELCORP" },
                new OldSymbol { old_symbol = "PRSMJOHNSN", new_symbol = "PRISMCEM" },
                new OldSymbol { old_symbol = "UTIBANK", new_symbol = "AXISBANK" },
            };

            List<InvestmentPrice> priceHistory = new List<InvestmentPrice>();
            using (TextReader reader = new StringReader(csvContent))
            {
                csv = new CsvReader(reader);
                while (csv.Read())
                {
                    symbol = "";
                    companyID = 0;

                    symbol = csv.GetField<string>("Symbol");
                    string series = csv.GetField<string>("Series");
                    string date = csv.GetField<string>("Date");
                    string open = csv.GetField<string>("Open Price");
                    string high = csv.GetField<string>("High Price");
                    string low = csv.GetField<string>("Low Price");
                    string close = csv.GetField<string>("Close Price");
                    string lastTrade = csv.GetField<string>("Last Price");
                    string prev = csv.GetField<string>("Prev Close");
                    string turnOver = csv.GetField<string>("Turnover");
                    DateTime dt = DataTypeHelper.ToDateTime(date);
                    if (string.IsNullOrEmpty(symbol) == false)
                    {
                        symbol = symbol.Replace("&amp;", "&");

                        companyID = (from q in companies
                                     where q.Symbol == symbol
                                     select q.CompanyID
                                            ).FirstOrDefault();

                        if (companyID <= 0)
                        {
                            return BadRequest("CompanyID does not exist");
                        }
                        else
                        {
                            priceHistory.Add(new InvestmentPrice
                            {
                                CompanyID = companyID,
                                Date = dt,
                                Close = DataTypeHelper.ToDecimal(close),
                                High = DataTypeHelper.ToDecimal(high),
                                Low = DataTypeHelper.ToDecimal(low),
                                Open = DataTypeHelper.ToDecimal(open),
                                PrevClose = DataTypeHelper.ToDecimal(prev),
                            });
                        }
                    }
                }
            }

            priceHistory = (from q in priceHistory
                            orderby q.Date ascending
                            select q).ToList();

            foreach (var price in priceHistory)
            {
                sql = "";
                sql = "INSERT INTO [dbo].[CompanyPriceHistory]" + Environment.NewLine +
                " ([CompanyID]" + Environment.NewLine +
                ",[Date]" + Environment.NewLine +
                ",[Open]" + Environment.NewLine +
                ",[Low]" + Environment.NewLine +
                ",[High]" + Environment.NewLine +
                ",[Close]" + Environment.NewLine +
                ",[PrevClose]" + Environment.NewLine +
                ",[OriginalOpen]" + Environment.NewLine +
                ",[OriginalLow]" + Environment.NewLine +
                ",[OriginalHigh]" + Environment.NewLine +
                ",[OriginalClose]" + Environment.NewLine +
                ",[OriginalPrevClose]" + Environment.NewLine +
               " ) VALUES (" + Environment.NewLine +
               "@companyID" + Environment.NewLine +
               ",@date" + Environment.NewLine +
               ",@open" + Environment.NewLine +
               ",@low" + Environment.NewLine +
               ",@high" + Environment.NewLine +
               ",@close" + Environment.NewLine +
               ",@prevclose" + Environment.NewLine +
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
            if (companyID > 0)
            {
                //ICompanyRepository repository = new CompanyRepository();
                //repository.CreateEquitySplit(companyID);
                //repository.UpdateCompanyHistory(companyID);
            }
            return Ok();
        }

    }

    public class OldSymbol
    {
        public string old_symbol { get; set; }
        public string new_symbol { get; set; }
    }
}