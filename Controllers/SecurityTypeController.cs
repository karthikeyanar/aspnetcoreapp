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
    [Route ("api/[controller]/[action]")]
    [ApiController]
    public class SecurityTypeController : ControllerBase {
        private readonly IConfiguration configuration;
        public SecurityTypeController (IConfiguration config) {
            configuration = config;
        }

        #region snippet_Get
        [HttpGet]
        public ActionResult<PaginatedListResult<SecurityTypeModel>> Get ([FromQuery] SearchModel criteria,[FromQuery] Paging paging) {
            ISecurityTypeRepository repository = new SecurityTypeRepository();
            return repository.Get(criteria,paging);
        }
        #endregion

    }

}