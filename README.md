# **Task Management MVC Web App**

### **Framework**
- **ASP.NET Core 6.0**

### **Database**
- **SQL Server**

## **Setup Instructions**

Follow these steps to set up the project:

1. **Create Database**  
   Create a new database in SQL Server named `task_mgmt`.

2. **Execute SQL Script**  
   Execute the `DB_task_mgmt.sql` script in your SQL Server instance. You can find this file in the root directory of the project.

3. **Update Database Connection Settings**  
   Open the solution file `TaskManagement.sln` located in the root directory. Navigate to `\TaskManagement\Repo\RepoTask.cs` and update the following variables with your database server details:
   - **`DB_SERVER`**
   - **`DB_USERNAME`**
   - **`DB_PWD`**

4. **Run the Project**  
   Once the above steps are completed, run the project.
