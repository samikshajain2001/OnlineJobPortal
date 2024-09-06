using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;

namespace OnlineJobPortal.User
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username, password = string.Empty;
            String str = ConfigurationManager.ConnectionStrings["cs"].ConnectionString;
            try
            {   
                if(ddlLoginType.SelectedValue == "Admin")
                {
                    username = ConfigurationManager.AppSettings["username"];
                    password = ConfigurationManager.AppSettings["password"];
                    if (username == txtUserName.Text.Trim() && password == txtPassword.Text.Trim())
                    {
                        Session["admin"] = username;
                        Response.Redirect("~/Admin/Dashboard.aspx", false);
                    }
                    else
                    {
                        showErrorMsg("Admin");
                    }
                }
                else
                {
                    using (SqlConnection con = new SqlConnection(str))
                    {
                        String query = "Select * from [User] where Username = @Username and Password = @Password";
                        SqlCommand cmd = new SqlCommand(query, con);
                        cmd.Parameters.AddWithValue("@Username", txtUserName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Password", txtPassword.Text.Trim());

                        con.Open();
                        SqlDataReader sdr = cmd.ExecuteReader();
                        if (sdr.Read())
                        {
                            Session["user"] = sdr["Username"].ToString();
                            Session["userId"] = sdr["UserId"].ToString();
                            Response.Redirect("Default.aspx", false);
                        }
                        else
                        {
                            showErrorMsg("User");
                        }
                        con.Close();
                    }
                }

            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('" + ex.Message + "');<script>");
            }

        }

        private void clear()
        {
            txtUserName.Text = string.Empty;
            txtPassword.Text = string.Empty;
        }

        private void showErrorMsg(string usertype)
        {
            lblMsg.Visible = true;
            lblMsg.Text = "<b>" + usertype + "</b> credentials are incorrect..!";
            lblMsg.CssClass = "alert alert-danger";
        }
    }
}