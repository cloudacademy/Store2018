using System;
namespace InventoryService.Models
{
    public class Product
    {
        public Product()
        {
        }

        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Sku { get; set; }
        public decimal RegularPrice { get; set; }
        public decimal DiscountPrice { get; set; }
        public int Quantity { get; set; }
    }
}
