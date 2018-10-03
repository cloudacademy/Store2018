using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using AccountService.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AccountService.Controllers
{
    [Route("api/[controller]")]
    public class ConsumersController : Controller
    {
        // GET: api/consumers
        [HttpGet]
        public ActionResult<IEnumerable<Consumer>> Get()
        {
            //stub
            //method would actually make SQL READ all from database

            var consumers = new List<Consumer>()
            {
                new Consumer(){
                    Id = 111,
                    Firstname = "Jeremy",
                    Surname = "Cook",
                    Age = 40
                },
                new Consumer(){
                    Id = 112,
                    Firstname = "Bob",
                    Surname = "Smith",
                    Age = 48
                },
                new Consumer(){
                    Id = 113,
                    Firstname = "John",
                    Surname = "Doe",
                    Age = 21
                },
                new Consumer(){
                    Id = 114,
                    Firstname = "Mary",
                    Surname = "Doe",
                    Age = 35
                }
            };

            return consumers;
        }

        // GET api/consumers/5
        [HttpGet("{id}")]
        public ActionResult<Consumer> Get(int id)
        {
            //stub
            //method would actually make SQL READ from database
            //with WHERE clause on id

            var consumer = new Consumer()
            {
                Id = id,
                Firstname = "Jeremy",
                Surname = "Cook",
                Age = 20
            };

            return consumer;
        }

        // POST api/consumers
        [HttpPost]
        public ActionResult<Consumer> Post([FromBody]Consumer consumer)
        {
            //stub
            //method would actually make SQL WRITE into database
            var saved_consumer = new Consumer()
            {
                Id = 100,
                Firstname = consumer.Firstname,
                Surname = consumer.Surname,
                Age = consumer.Age
            };

            return saved_consumer;
        }

        // PUT api/consumers/5
        [HttpPut("{id}")]
        public ActionResult<Consumer> Put(int id, [FromBody]Consumer consumer)
        {
            //stub
            //method would actually make SQL UPDATE into database

            var updated_consumer = new Consumer()
            {
                Id = id,
                Firstname = consumer.Firstname,
                Surname = consumer.Surname,
                Age = consumer.Age
            };

            return updated_consumer;
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
