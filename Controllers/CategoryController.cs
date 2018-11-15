
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using aspnetcoreapp.Helpers;
using aspnetcoreapp.Models;
using aspnetcoreapp.Repository;
using CsvHelper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly IConfiguration configuration;
        public CategoryController(IConfiguration config)
        {
            configuration = config;
        }

        [HttpGet]
        public ActionResult<PaginatedListResult<CategoryModel>> List([FromQuery] SearchModel criteria)
        {
            ICategoryRepository repository = new CategoryRepository();
            return repository.Get(criteria);
        }

        [HttpPost]
        public ActionResult Save(CategoryModel model)
        {
            ICategoryRepository repository = new CategoryRepository();
            return Ok(repository.Save(model));
        }

        [HttpGet]
        public ActionResult Delete([FromQuery] int id)
        {
            ICategoryRepository repository = new CategoryRepository();
            repository.Delete(id);
            return Ok();
        }

    }

}