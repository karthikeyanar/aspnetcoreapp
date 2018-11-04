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
    }
}