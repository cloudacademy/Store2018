using System;
namespace AccountService.Models
{
    public class Consumer
    {
        public Consumer()
        {
        }

        public int Id { get; set; }
        public string Firstname { get; set; }
        public string Surname { get; set; }
        public int Age { get; set; }
    }
}
