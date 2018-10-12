using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Reflection;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Helpers {
    public class PaginatedListResult<T> {
        public int total;
        public IEnumerable<T> rows;
    }

    public class Paging {

        public Paging () {
            this.PageSize = 10;
            this.PageIndex = 1;
            this.SortName = "id";
            this.SortOrder = "asc";
            this.Total = 0;
        }

        public int PageIndex { get; set; }

        public int PageSize { get; set; }

        public string SortName { get; set; }

        public string SortOrder { get; set; }

        public int Total { get; set; }
    }

    public class ConfigHelper {

        private static ConfigHelper _appSettings;

        public string appSettingValue { get; set; }

        public static string AppSetting (string section, string key) {
            _appSettings = GetCurrentSettings (section, key);
            return _appSettings.appSettingValue;
        }

        public ConfigHelper (IConfiguration config, string key) {
            this.appSettingValue = config.GetValue<string> (key);
        }

        public static ConfigHelper GetCurrentSettings (string section, string key) {
            var builder = new ConfigurationBuilder ()
                .SetBasePath (Directory.GetCurrentDirectory ())
                .AddJsonFile ("appsettings.json", optional : false, reloadOnChange : true)
                .AddEnvironmentVariables ();

            IConfigurationRoot configuration = builder.Build ();

            var settings = new ConfigHelper (configuration.GetSection (section), key);

            return settings;
        }
    }

    public class Helper {
        public static string ConnectionString {
            get {
                return ConfigHelper.AppSetting("ConnectionStrings","DefaultConnection");
            }
        }
        public static string RootPath {
            get {
                return ConfigHelper.AppSetting("AppSettings","RootPath");
            }
        }
        public static string ReplaceOrderBy(string sql, string orderby) {
            string string1 = "--{{ORDER_BY_START}}";
            string string2 = "--{{ORDER_BY_END}}";
            string result = sql;
            try {
                string firstPart = sql.Split(new string[] { string1 }, StringSplitOptions.None)[0];
                string secondPart = sql.Split(new string[] { string2 }, StringSplitOptions.None)[1];
                sql = (firstPart + " " + orderby + " " + secondPart).Trim();
            } catch {
                sql = result;
            }
            return sql;
        }
        public static string ReplaceParams(string sql, string sqlParams) {
            return sql.Replace("--{{PARAMS}}",sqlParams);
        }
    }

    public class SqlHelper {
        public static List<T> GetList<T> (string sql) where T : new () {
            string connectionString = Helper.ConnectionString;
            Type businessEntityType = typeof (T);
            List<T> entitys = new List<T> ();
            //Hashtable hashtable = new Hashtable();
            PropertyInfo[] properties = businessEntityType.GetProperties ();
            using (SqlConnection connection = new SqlConnection (connectionString)) {
                connection.Open ();
                using (SqlCommand command = new SqlCommand (sql, connection)) {
                    using (SqlDataReader dr = command.ExecuteReader ()) {
                        while (dr.Read ()) {
                            T newObject = new T ();
                            for (int index = 0; index < dr.FieldCount; index++) {
                                PropertyInfo info = businessEntityType.GetProperty (dr.GetName (index)); // properties.Select(q => q.Name == dr.GetName(index)).FirstOrDefault(); // (PropertyInfo)hashtable[dr.GetName(index).ToUpper()];
                                if ((info != null) && info.CanWrite) {
                                    SetValue (newObject, info, dr.GetValue (index));
                                    //info.SetValue(newObject,dr.GetValue(index).ToString());
                                    //info.SetValue(newObject,dr.GetValue(index),null);
                                }
                            }
                            entitys.Add (newObject);
                        }
                        dr.Close ();
                    }
                }
            }
            return entitys;
        }

        public static void SetValue (object inputObject, PropertyInfo propertyInfo, object propertyVal) {
            if ((propertyVal == DBNull.Value) == false) {
                Type propertyType = propertyInfo.PropertyType;
                //Convert.ChangeType does not handle conversion to nullable types
                //if the property type is nullable, we need to get the underlying type of the property
                var targetType = IsNullableType (propertyInfo.PropertyType) ? Nullable.GetUnderlyingType (propertyInfo.PropertyType) : propertyInfo.PropertyType;
                //Returns an System.Object with the specified System.Type and whose value is
                //equivalent to the specified object.
                propertyVal = Convert.ChangeType (propertyVal, targetType);
                //Set the value of the property
                propertyInfo.SetValue (inputObject, propertyVal, null);
            }
        }

        private static bool IsNullableType (Type type) {
            return type.IsGenericType && type.GetGenericTypeDefinition ().Equals (typeof (Nullable<>));
        }
    }
}