using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using aspnetcoreapp.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
/*
namespace aspnetcoreapp.Models {
    [ModelMetadataType(typeof(PostMD))]
    public partial class Post {
        public class PostMD {
            [Required(ErrorMessage = "BlogId is required")]
            [Range((int) ConfigUtil.IDStartRange, int.MaxValue, ErrorMessage = "BlogId is required")]
            public int BlogId {
                get;
                set;
            }
        }

        [NotMapped]
        public string BlogUrl { get; set; }

        public IEnumerable<ErrorInfo> Save() {
            IEnumerable<ErrorInfo> errors = ValidationHelper.Validate(this);
            if (errors.Any()) {
                return errors;
            }
            //Save
            using(BlogContext context = new BlogContext()) {
                if (this.PostId > 0)
                    context.Entry(this).State = EntityState.Modified;
                else
                    context.Post.Add(this);

                context.SaveChanges();
            }
            return null;
        }
    }
}
*/