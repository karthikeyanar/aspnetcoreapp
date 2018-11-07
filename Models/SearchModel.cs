using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models
{
    public class SearchModel : Paging
    {
        public bool? IsBookMarkCategory { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? LastTradingDate { get; set; }

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