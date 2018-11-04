using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models {
    public class SearchModel : Paging {
        public bool? IsBookMarkCategory {get; set;}
        public DateTime? FromDate {get;set;}
    }
}