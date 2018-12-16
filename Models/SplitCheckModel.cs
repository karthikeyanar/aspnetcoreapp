using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models
{
    public class SplitCheckModel
    {
        public int CompanyID { get; set; }
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public decimal? SplitFactor { get; set; }
        public DateTime? SplitDate {get;set;}
        public decimal? Percentage {get;set;}
        public decimal? Open {get;set;}
        public decimal? PrevClose {get;set;}
    }
 
}