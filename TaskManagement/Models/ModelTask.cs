using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace TaskManagement.Models
{
    public class ModelTask
    {
        public int Id { get; set; }

        public string Title { get; set; }
        public string Descr { get; set; }
        public DateTime DateCreate { get; set; }
        public DateTime LogDate { get; set; }
        public string Status { get; set; }
        public string StatusDescr { get; set; }
    }
}
