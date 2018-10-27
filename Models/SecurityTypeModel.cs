using System.ComponentModel.DataAnnotations;
using aspnetcoreapp.Helpers;

namespace aspnetcoreapp.Models {
    public class SecurityTypeModel {
        [Key]
        public int SecurityTypeID { get; set; }
        public string Name { get; set; }

        
    }

    public class SearchModel {
        public string Name { get; set; }
    }
}