using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Store2018.Controllers
{
    public class HealthCheckController : Controller
    {
        // GET: /<controller>/
        public string Index()
        {
            return "OK";
        }
    }
}
