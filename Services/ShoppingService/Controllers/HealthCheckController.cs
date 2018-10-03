using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ShoppingService.Controllers
{
    [Route("api/[controller]")]
    public class HealthCheckController : Controller
    {
        // GET: api/healthcheck
        [HttpGet]
        public string Get()
        {
            return "OK";
        }
    }
}