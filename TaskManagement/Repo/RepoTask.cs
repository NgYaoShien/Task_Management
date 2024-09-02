using Dapper;
using System.Data;
using System.Data.SqlClient;
using System.Xml.Linq;
using TaskManagement.Models;

namespace TaskManagement.Repo
{
    public class RepoTask
    {
        const String DB_SERVER = "localhost";
        const String DB_NAME = "task_mgmt";
        const String DB_USERNAME = "";
        const String DB_PWD = "";
        const String CONNECTION_STR = "Data Source=" + DB_SERVER + ";Initial Catalog="+ DB_NAME + ";Integrated Security=False;User Id=" + DB_USERNAME + ";Password=" + DB_PWD + ";TrustServerCertificate=true;";

        public List<ModelTask> GetAllTask()
        {

            string sQuery = "SELECT * FROM [vwTaskList] WHERE [Status]<>'X'";
            using (SqlConnection connection = new SqlConnection(CONNECTION_STR))
            {
                connection.Open();
                return connection.Query<ModelTask>(sQuery).ToList();
            }
        }

        public ModelTask GetTaskById(int task_id)
        {

            string sQuery = "SELECT * FROM [vwTaskList] WHERE [Id]=@Id";
            using (SqlConnection connection = new SqlConnection(CONNECTION_STR))
            {
                connection.Open();
                return connection.Query<ModelTask>(sQuery, new { Id = task_id }).FirstOrDefault();
            }
        }

        public bool InsertTask(string title, string descr, out string error_msg)
        {
            using (SqlConnection connection = new SqlConnection(CONNECTION_STR))
            {
                connection.Open();
                using (SqlCommand cmd = new SqlCommand("spTask_AddNew", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@Title", title)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Descr", descr)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Id", SqlDbType.BigInt)).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(new SqlParameter("@Msg", SqlDbType.NVarChar, -1));
                    cmd.Parameters["@Msg"].Direction = ParameterDirection.Output;

                    cmd.ExecuteScalar();

                    error_msg = cmd.Parameters["@Msg"].SqlValue.ToString();
                    Int64 response_id = Int32.Parse(cmd.Parameters["@Id"].SqlValue.ToString());

                    return (response_id > 0);
                }
            }
        }
        public bool UpdateTask(int task_id, string title, string descr, out string error_msg)
        {
            using (SqlConnection connection = new SqlConnection(CONNECTION_STR))
            {
                connection.Open();
                using (SqlCommand cmd = new SqlCommand("spTask_Update", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@TId", task_id)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Title", title)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Descr", descr)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Id", SqlDbType.BigInt)).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(new SqlParameter("@Msg", SqlDbType.NVarChar, -1));
                    cmd.Parameters["@Msg"].Direction = ParameterDirection.Output;

                    cmd.ExecuteScalar();

                    error_msg = cmd.Parameters["@Msg"].SqlValue.ToString();
                    Int64 response_id = Int32.Parse(cmd.Parameters["@Id"].SqlValue.ToString());

                    return (response_id > 0);
                }
            }
        }

        public bool UpdateStatus(int task_id, string status, out string error_msg)
        {
            using (SqlConnection connection = new SqlConnection(CONNECTION_STR))
            {
                connection.Open();
                using (SqlCommand cmd = new SqlCommand("spTask_UpdateStatus", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@TId", task_id)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Status", status)).Direction = ParameterDirection.Input;
                    cmd.Parameters.Add(new SqlParameter("@Id", SqlDbType.BigInt)).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(new SqlParameter("@Msg", SqlDbType.NVarChar, -1));
                    cmd.Parameters["@Msg"].Direction = ParameterDirection.Output;

                    cmd.ExecuteScalar();

                    error_msg = cmd.Parameters["@Msg"].SqlValue.ToString();
                    Int64 response_id = Int32.Parse(cmd.Parameters["@Id"].SqlValue.ToString());

                    return (response_id > 0);
                }
            }
        }
    }
}
