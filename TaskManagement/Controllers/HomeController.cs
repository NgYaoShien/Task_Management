using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Threading.Tasks;
using TaskManagement.Models;
using TaskManagement.Repo;

namespace TaskManagement.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            var repo = new RepoTask();
            var ModelTask = repo.GetAllTask();
            if (ModelTask == null)
            {
                return RedirectToAction("Index");
            }

            return View(ModelTask);
        }

        [HttpPost]
        public IActionResult Index([FromForm] ModelTask model)
        {
            var repo = new RepoTask();
            //string Title = model.Title ?? "Default";
            //string Descr = model.Descr ?? "";
            string Title = model.Title;
            string Descr = model.Descr;
            string error_msg = "";

            if (repo.InsertTask(Title, Descr, out error_msg))
            {
                TempData["SUCCESS"] = "Added new task successfully !";
            }
            else
            {
                TempData["ERROR"] = error_msg;
            }

            return RedirectToAction("Index");
        }

        [HttpGet]
        public IActionResult Edit(int taskid)
        {
            var repo = new RepoTask();

            var ModelTask = repo.GetTaskById(taskid);
            if (ModelTask == null)
            {
                return RedirectToAction("Index");
            }

            return View(ModelTask);
        }

        [HttpPost]
        public IActionResult Edit([FromForm] ModelTask model, string action_name)
        {
            var repo = new RepoTask();
            int TaskId = model.Id;
            string Title = model.Title;
            string Descr = model.Descr;
            string error_msg = "";

            if (action_name == "edit")
            {
                if (repo.UpdateTask(TaskId, Title, Descr, out error_msg))
                {
                    TempData["SUCCESS"] = "Task update successfully!";
                }
                else
                {
                    TempData["ERROR"] = error_msg;
                }
            }
            else if (action_name == "complete")
            {
                if (repo.UpdateStatus(TaskId, "A", out error_msg))
                {
                    TempData["SUCCESS"] = "This task has mark as Completed !";
                }
                else
                {
                    TempData["ERROR"] = error_msg;
                }
            }
            else if (action_name == "delete")
            {
                if (repo.UpdateStatus(TaskId, "X", out error_msg))
                {
                    TempData["SUCCESS"] = "Task has been deleted !";
                    return RedirectToAction("Index");
                }
                else
                {
                    TempData["ERROR"] = error_msg;
                }
            }

            return RedirectToAction("Edit", new { taskid = TaskId });
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}