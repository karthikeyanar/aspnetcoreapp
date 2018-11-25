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

        public DateTime? LastTradingDate { get; set; }
    }


    public class CompanyFundamental
    {
        public int CompanyID { get; set; }
        public decimal? ROE { get; set; }
        public decimal? ROE_3_Years { get; set; }
        public decimal? ROCE { get; set; }
        public decimal? ROCE_3_Years { get; set; }
        public decimal? StockPE { get; set; }
        public decimal? DividendYield { get; set; }
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
        public decimal? DE { get; set; }
        public decimal? PEG { get; set; }
        public decimal? EPS { get; set; }
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
    }
}