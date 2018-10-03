using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using ShoppingService.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ShoppingService.Controllers
{
    [Route("api/[controller]")]
    public class CartController : Controller
    {
        // GET: api/cart
        [HttpGet]
        public IEnumerable<int> Get()
        {
            return new int[] { 100, 101, 102, 103, 200, 201, 600 };
        }

        // GET api/cart/5
        [HttpGet("{id}")]
        public ActionResult<Cart> Get(int id)
        {
            var cart = new Cart()
            {
                Id = id,
                Items = new List<Product>()
                {
                    new Product()
                    {
                        Id = 33,                        
                        Description = "",
                        Sku = "abc123",
                        Name = "Laptop",
                        DiscountPrice = 20.99m,
                        RegularPrice = 29.99m,
                        Quantity = 82
                    },
                    new Product()
                    {
                        Id = 14,                        
                        Description = "",
                        Sku = "xyz1238",
                        Name = "iPhone",
                        DiscountPrice = 20.99m,
                        RegularPrice = 29.99m,
                        Quantity = 67
                    },
                    new Product()
                    {
                        Id = 20,
                        Description = "",
                        Sku = "xyz1239",
                        Name = "Jacket",
                        DiscountPrice = 20.99m,
                        RegularPrice = 29.99m,
                        Quantity = 405
                    }
                }
            };

            return cart;
        }

        // POST api/cart
        [HttpPost]
        public ActionResult<Cart> Post([FromBody]Cart cart)
        {
            //stub
            //method would actually make SQL WRITE into database
            var saved_cart = new Cart()
            {
                Id = 100,
                Items = cart.Items
            };

            return saved_cart;
        }

        // PUT api/cart/5
        [HttpPut("{id}")]
        public ActionResult<Cart> Put(int id, [FromBody]Cart cart)
        {
            //stub
            //method would actually make SQL WRITE into database
            var updated_cart = new Cart()
            {
                Id = id,
                Items = cart.Items
            };

            return updated_cart;
        }

        // DELETE api/cart/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
            //stub
            //method would actually make SQL DELETE into database
        }
    }
}
