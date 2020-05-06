
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
    public class ReportController : ControllerBase {
        private readonly IConfiguration configuration;
        public ReportController(IConfiguration config) {
            configuration = config;
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<MonthlyModel>> Monthly([FromQuery] SearchModel criteria) {
            IReportRepository repository = new ReportRepository();
            return repository.GetMonthly(criteria);
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<DailyModel>> Daily([FromQuery] SearchModel criteria) {
            IReportRepository repository = new ReportRepository();
            return repository.GetDaily(criteria);
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<CAGRModel>> CAGR([FromQuery] SearchModel criteria) {
            IReportRepository repository = new ReportRepository();
            return repository.GetCAGR(criteria);
        }
 
    }

}