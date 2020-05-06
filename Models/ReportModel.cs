using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models {
    public class MonthlyModel {
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public decimal? Percentage {get;set;}
        public decimal? PrevPercentage {get;set;}
        public DateTime? FromDate {get;set;}
        public DateTime? ToDate {get; set;}
        public DateTime? PrevFromDate {get;set;}
        public DateTime? PrevToDate {get; set;}
        public string InvestingUrl { get; set; }
        public DateTime? LastTradingDate { get; set; }
        public int? CompanyID {get;set;}
    }

    public class DailyModel {
        public DateTime? Date { get; set; }
        public decimal? Percentage {get;set;}
    }

    public class CAGRModel {
        public int? CompanyID {get;set;}
        public string CompanyName {get;set;}
        public string Symbol {get;set;}
        public string Category {get;set;}
        public decimal? Year_3 {get;set;}
        public decimal? Year_5 {get;set;}
        public decimal? Year_7 {get;set;}
        public decimal? Year_10 {get;set;}
        public decimal? CAGR {get;set;}
        public int? DateDiff2 {get;set;}
        public bool? IsBookMark {get;set;}
    }
}