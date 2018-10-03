using System;
using System.Collections.Generic;

namespace Store2018.Models
{
    public class Commerce
    {
        public Consumer User { get; set; }
        public List<Product> Products { get; set; }
        public Cart Cart { get; set; }
    }
}
