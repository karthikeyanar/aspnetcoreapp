using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models {
    public class CategoryModel {
        public int CategoryID {get;set;}
        public string CategoryName { get; set; }
        public bool? IsBookMark {get;set;}
        public bool? IsArchive {get;set;}
    }
}