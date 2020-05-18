using System;
using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models {
    public class PortfolioTransactionModel {
        public int PortfolioTransactionID { get; set; }
        public int CompanyID { get; set; }
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public int TransactionTypeID { get; set; }
        public string TransactionTypeName { get; set; }
        public DateTime TransactionDate { get; set; }
        public int Quantity { get; set; }
        public decimal CostPerShare { get; set; }
        public decimal Amount {get; set;}
    }

    public class PortfolioModel {
        public int PortfolioID { get; set; }
        public int CompanyID { get; set; }
        public string CompanyName { get; set; }
        public string Symbol { get; set; }
        public string CategoryName {get; set;}
        public int Quantity { get; set; }
        public decimal AverageCost { get; set; }
        public decimal TotalInvestment {get; set;}
        public decimal ClosePrice {get; set;}
        public decimal CurrentMarketValue {get; set;}
        public decimal ProfitPercentage {get; set;}
    }

}