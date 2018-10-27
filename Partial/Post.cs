using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace aspnetcoreapp.Models {
    public partial class Post {
        [NotMapped]
        public string BlogUrl { get; set; }
    }
}