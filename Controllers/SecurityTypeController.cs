using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using aspnetcoreapp.Models;

namespace aspnetcoreapp.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class SecurityTypeController : ControllerBase
    {
        private readonly IConfiguration configuration;
        public SecurityTypeController(IConfiguration config)
        {
             configuration = config;
        }

        #region snippet_Get
        [HttpGet]
        public ActionResult<List<SecurityTypeModel>> Get()
        {
            string sql = "select * from securitytype";
            return SqlHelper.GetList<SecurityTypeModel>(configuration.GetConnectionString("DefaultConnection"),sql);
        }
        #endregion
 
    }

   
}