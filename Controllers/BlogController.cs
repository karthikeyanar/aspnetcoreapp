using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using aspnetcoreapp.Repository;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Controllers {
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class BlogController : ControllerBase {

        private readonly IConfiguration configuration;
        public BlogController(IConfiguration config) {
            configuration = config;
        }

        #region snippet_Get
        [HttpGet]
        public ActionResult<PaginatedListResult<Blog>> List([FromQuery] SearchModel criteria, [FromQuery] Paging paging) {
             IBlogRepository repository = new BlogRepository();
             return repository.List(criteria,paging);
        }
        #endregion
 
    }

}