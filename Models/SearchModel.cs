using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models
{
    public class SearchModel : Paging
    {
        public int? CompanyID {get;set;}
        public int? CategoryID {get;set;}
        public bool? IsBookMarkCategory { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? LastTradingDate { get; set; }
        public string CompanyIDs {get; set;}
        public string CategoryIDs {get; set;}
        public bool? IsBookMark {get;set;}
        public bool? IsArchive {get;set;}
        public string csv {get;set;}
    }

     public class InvestmentPrice {
        public int CompanyID { get; set; }
        public DateTime Date { get; set; }
        public decimal Open { get; set; }
        public decimal Close { get; set; }
        public decimal High { get; set; }
        public decimal Low { get; set; }
        public decimal PrevClose { get; set; }
    }
}