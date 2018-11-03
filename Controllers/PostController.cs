using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using aspnetcoreapp.Repository;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Controllers {
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class PostController : ControllerBase {
        private readonly IConfiguration configuration;
        public PostController(IConfiguration config) {
            configuration = config;
        }

        #region snippet_Get
        [HttpGet]
        public ActionResult<List<Post>> List([FromQuery] SearchModel criteria, [FromQuery] Paging paging) {
            using(BlogContext context = new BlogContext()) {
                var post = new Post {
                BlogId = 1,
                Content = "Test Post",
                Title = "Post 1"
                };
                context.Post.Add(post);
                context.SaveChanges();
                return (from q in context.Post join blog in context.Blog on q.BlogId equals blog.BlogId select new Post {
                    BlogId = q.BlogId,
                        PostId = q.PostId,
                        Content = q.Content,
                        Title = q.Title,
                        BlogUrl = blog.Url
                }).ToList();
            }
        }
        #endregion

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create([FromBody] Post post) {
            if (!ModelState.IsValid) {
                return BadRequest(ModelState);
            }
            return Ok(post.Save());
        }

    }

}