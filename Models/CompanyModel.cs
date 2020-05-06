using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models
{
    public class CompanyModel
    {
        public int CompanyID { get; set; }
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public bool? IsBookMark { get; set; }
        public bool? IsArchive { get; set; }
        public string InvestingUrl { get; set; }
        public string MoneyControlSymbol { get; set; }
        public string MoneyControlUrl { get; set; }
        public decimal? MarketCapital {get;set;}

        public DateTime? LastTradingDate { get; set; }
    }

    public class CompanyPriceAverageModel: CompanyModel
    {
        public decimal? CurrentPrice { get; set; }
        public decimal? MA5 { get; set; }
        public decimal? MA10 { get; set; }
        public decimal? MA20 { get; set; }
        public decimal? MA50 { get; set; }
        public decimal? MA100 { get; set; }
        public decimal? MA200 { get; set; }

        public bool? IsBuy_MA5 { get; set; }
        public bool? IsBuy_MA10 { get; set; }
        public bool? IsBuy_MA20 { get; set; }
        public bool? IsBuy_MA50 { get; set; }
        public bool? IsBuy_MA100 { get; set; }
        public bool? IsBuy_MA200 { get; set; }

        public DateTime? LastUpdatedDate {get;set;}
    }


    public class CompanyFundamentalModel : CompanyModel
    {
        public decimal? ROCE { get; set; }
        public decimal? StockPE { get; set; }
        public decimal? DividendYield { get; set; }
        public decimal? ROE { get; set; }
        public decimal? ROE_3_Years { get; set; }
        public decimal? ROE_5_Years { get; set; }
        public decimal? ROE_7_Years { get; set; }
        public decimal? ROE_10_Years { get; set; }
        public decimal? SalesGrowth { get; set; }
        public decimal? SalesGrowth_3_Years { get; set; }
        public decimal? SalesGrowth_5_Years { get; set; }
        public decimal? SalesGrowth_7_Years { get; set; }
        public decimal? SalesGrowth_10_Years { get; set; }
        public decimal? ProfitGrowth { get; set; }
        public decimal? ProfitGrowth_3_Years { get; set; }
        public decimal? ProfitGrowth_5_Years { get; set; }
        public decimal? ProfitGrowth_7_Years { get; set; }
        public decimal? ProfitGrowth_10_Years { get; set; }
        public decimal? EPS_Year_1 { get; set; }
        public decimal? EPS_Year_2 { get; set; }
        public decimal? EPS_Year_3 { get; set; }
        public decimal? EPS_Quater_1 { get; set; }
        public decimal? EPS_Quater_2 { get; set; }
        public decimal? NetProfit_Quater_1 { get; set; }
        public decimal? NetProfit_Quater_2 { get; set; }
        public decimal? NetProfit_Quater_3 { get; set; }
        public decimal? NetProfit_Quater_4 { get; set; }
        public decimal? NetProfit_Year_1 { get; set; }
        public decimal? NetProfit_Year_2 { get; set; }
        public decimal? NetProfit_Year_3 { get; set; }
        public decimal? DE { get; set; }
        public decimal? PEG { get; set; }
        public decimal? Interest { get; set; }
        public decimal? PromoterHolding { get; set; }
        public decimal? BookValue { get; set; }
        public decimal? FaceValue { get; set; }
        public decimal? CurrentPrice { get; set; }
        public decimal? MarketCapital { get; set; }
        public decimal? Week52High { get; set; }
        public decimal? Week52Low { get; set; }
        public decimal? PiotroskiScore { get; set; }
        public decimal? GFactor { get; set; }
        public decimal? PS { get; set; }
        public decimal? PB { get; set; }
        public DateTime? LastUpdatedDate { get; set; }
        public string QuaterProfits { get; set; }
        public string YearProfits { get; set; }
        public string QuaterSales { get; set; }
        public string YearSales { get; set; }


        //Others
        public string Categories { get; set; }
        public decimal? AvgYearProfit { get; set; }
        public int? Positive { get; set; }
        public int? Negative { get; set; }
        public int? TotalYears { get; set; }
        public decimal? Profit_2009 { get; set; }
        public decimal? Profit_2010 { get; set; }
        public decimal? Profit_2011 { get; set; }
        public decimal? Profit_2012 { get; set; }
        public decimal? Profit_2013 { get; set; }
        public decimal? Profit_2014 { get; set; }
        public decimal? Profit_2015 { get; set; }
        public decimal? Profit_2016 { get; set; }
        public decimal? Profit_2017 { get; set; }
        public decimal? Profit_2018 { get; set; }
    }

    public class CompanyShareHoldingModel
    {
        public int CompanyID { get; set; }
        public int ShareHoldingTypeID { get; set; }
        public int? Total { get; set; }
        public int? TotalShares { get; set; }
    }

    public class ShareHoldingTypeModel
    {
        public int ShareHoldingTypeID { get; set; }
        public string ShareHoldingTypeName { get; set; }
    }

    public class LongTermModel
    {
        public int CompanyID { get; set; }
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public string Categories { get; set; }
        public decimal? AvgYearProfit { get; set; }
        public int? MutualFunds { get; set; }
        public int? QualifiedForeignInvestors { get; set; }
        public int? TotalInvestors { get; set; }
        public decimal? PositivePercentage { get; set; }
        public int? TotalYears { get; set; }
        public int? Positive { get; set; }
        public int? Negative { get; set; }
        public bool? IsBookMark { get; set; }
        public decimal? PEG { get; set; }
    }
}