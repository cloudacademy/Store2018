using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using InventoryService.Models;


namespace InventoryService.Controllers
{
    [Route("api/[controller]")]
    public class ProductsController : Controller
    {
        // GET: api/products
        [HttpGet]
        public ActionResult<IEnumerable<Product>> Get()
        {
            //stub
            //method would actually make SQL READ all from database

            var products = new List<Product>(){
                new Product()
                {
                    Id = 1,
                    Description = "",
                    Sku = "abc12300",
                    Name = "Toy1",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 2,
                    Description = "",
                    Sku = "xyz123",
                    Name = "Toy2",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 3,
                    Description = "",
                    Sku = "abc12300",
                    Name = "Toy3",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 4,
                    Description = "",
                    Sku = "xyz123",
                    Name = "Toy4",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 5,
                    Description = "",
                    Sku = "abc12300",
                    Name = "Toy5",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 6,
                    Description = "",
                    Sku = "xyz123",
                    Name = "Toy6",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 7,
                    Description = "",
                    Sku = "abc12300",
                    Name = "Toy7",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                },
                new Product()
                {
                    Id = 8,
                    Description = "",
                    Sku = "xyz123",
                    Name = "Toy8",
                    DiscountPrice = 20.99m,
                    RegularPrice = 29.99m,
                    Quantity = 100
                }
            };

            return products;
        }

        // GET api/products/5
        [HttpGet("{id}")]
        public ActionResult<Product> Get(int id)
        {
            //stub
            //method would actually make SQL READ from database
            //with WHERE clause on id

            var product = new Product()
            {
                Id = id,
                Description = "",
                Sku = "xyz123",
                Name = "Toy2",
                DiscountPrice = 20.99m,
                RegularPrice = 29.99m,
                Quantity = 100
            };

            return product;
        }

        // POST api/products
        [HttpPost]
        public ActionResult<Product> Post([FromBody]Product product)
        {
            //stub
            //method would actually make SQL INSERT into database
            var saved_product = new Product()
            {
                Id = 100,
                Description = product.Description,
                Sku = product.Sku,
                Name = product.Name,
                DiscountPrice = product.DiscountPrice,
                RegularPrice = product.RegularPrice,
                Quantity = product.Quantity
            };

            return saved_product;
        }

        // PUT api/products/5
        [HttpPut("{id}")]
        public ActionResult<Product> Put(int id, [FromBody]Product product)
        {
            //stub
            //method would actually make SQL UPDATE into database
            var updated_product = new Product()
            {
                Id = id,
                Description = product.Description,
                Sku = product.Sku,
                Name = product.Name,
                DiscountPrice = product.DiscountPrice,
                RegularPrice = product.RegularPrice,
                Quantity = product.Quantity
            };

            return updated_product;
        }

        // DELETE api/products/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
            //stub
            //method would actually make SQL DELETE in database
        }
    }
}
