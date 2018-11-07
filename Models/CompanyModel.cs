using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models {
    public class CompanyModel {
        public int CompanyID {get;set;}
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public bool? IsBookMark {get;set;}
        public bool? IsArchive {get;set;}
        public string InvestingUrl { get; set; }

        public DateTime? LastTradingDate {get;set;}
    }
}