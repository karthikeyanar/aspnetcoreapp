using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Reflection;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using aspnetcoreapp.Repository;
using CsvHelper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Controllers {
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class PortfolioController : ControllerBase {
        private readonly IConfiguration configuration;
        public PortfolioController(IConfiguration config) {
            configuration = config;
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<PortfolioTransactionModel>> List([FromQuery] SearchModel criteria) {
            IPortfolioRepository repository = new PortfolioRepository();
            return repository.Get(criteria);
        }

        [HttpPost]
        public ActionResult Save(PortfolioTransactionModel model) {
            IPortfolioRepository repository = new PortfolioRepository();
            return Ok(repository.Save(model));
        }

        [HttpGet]
        public ActionResult Delete([FromQuery] int id) {
            IPortfolioRepository repository = new PortfolioRepository();
            repository.Delete(id);
            return Ok();
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<PortfolioModel>> Investments([FromQuery] SearchModel criteria) {
            IPortfolioRepository repository = new PortfolioRepository();
            return repository.GetInvestments(criteria);
        }
    }
}