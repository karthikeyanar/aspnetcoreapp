using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace aspnetcoreapp.Helpers
{
    public class PaginatedListResult<T>
    {
        public int total;
        public IEnumerable<T> rows;
    }

    public class Paging
    {

        public Paging()
        {
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

    public class ConfigHelper
    {

        private static ConfigHelper _appSettings;

        public string appSettingValue { get; set; }

        public static string AppSetting(string section, string key)
        {
            _appSettings = GetCurrentSettings(section, key);
            return _appSettings.appSettingValue;
        }

        public ConfigHelper(IConfiguration config, string key)
        {
            this.appSettingValue = config.GetValue<string>(key);
        }

        public static ConfigHelper GetCurrentSettings(string section, string key)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddEnvironmentVariables();

            IConfigurationRoot configuration = builder.Build();

            var settings = new ConfigHelper(configuration.GetSection(section), key);

            return settings;
        }
    }

    public class Helper
    {
        public static string ConnectionString
        {
            get
            {
                return ConfigHelper.AppSetting("ConnectionStrings", "DefaultConnection");
            }
        }
        public static string RootPath
        {
            get
            {
                return ConfigHelper.AppSetting("AppSettings", "RootPath");
            }
        }
        public static string ReplaceOrderBy(string sql, string orderby)
        {
            string string1 = "--{{ORDER_BY_START}}";
            string string2 = "--{{ORDER_BY_END}}";
            string result = sql;
            try
            {
                string firstPart = sql.Split(new string[] { string1 }, StringSplitOptions.None)[0];
                string secondPart = sql.Split(new string[] { string2 }, StringSplitOptions.None)[1];
                sql = (firstPart + " " + orderby + " " + secondPart).Trim();
            }
            catch
            {
                sql = result;
            }
            return sql;
        }
        public static string ReplaceParams(string sql, string sqlParams)
        {
            return sql.Replace("--{{PARAMS}}", sqlParams);
        }

        public static DateTime MinDateTime
        {
            get
            {
                return Convert.ToDateTime("01/01/1900");
            }
        }
    }

    public class SqlHelper
    {
        public static int ExecuteNonQuery(string sql, List<SqlParameter> sqlParameterCollection)
        {
            string connectionString = Helper.ConnectionString;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    foreach (SqlParameter p in sqlParameterCollection){
                        command.Parameters.Add(p);
                    }
                    return command.ExecuteNonQuery();
                }
            }
        }
        public static object ExecuteScaler(string sql, List<SqlParameter> sqlParameterCollection)
        {
            string connectionString = Helper.ConnectionString;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    foreach (SqlParameter p in sqlParameterCollection){
                        command.Parameters.Add(p);
                    }
                    return command.ExecuteScalar();
                }
            }
        }
        public static List<T> GetList<T>(string sql, ref int totalRows) where T : new()
        {
            string connectionString = Helper.ConnectionString;
            Type businessEntityType = typeof(T);
            List<T> entitys = new List<T>();
            //Hashtable hashtable = new Hashtable();
            PropertyInfo[] properties = businessEntityType.GetProperties();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    using (SqlDataReader dr = command.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            totalRows = (int)dr["Count"];
                        }
                        dr.NextResult();
                        while (dr.Read())
                        {
                            T newObject = new T();
                            for (int index = 0; index < dr.FieldCount; index++)
                            {
                                PropertyInfo info = businessEntityType.GetProperty(dr.GetName(index)); // properties.Select(q => q.Name == dr.GetName(index)).FirstOrDefault(); // (PropertyInfo)hashtable[dr.GetName(index).ToUpper()];
                                if ((info != null) && info.CanWrite)
                                {
                                    SetValue(newObject, info, dr.GetValue(index));
                                    //info.SetValue(newObject,dr.GetValue(index).ToString());
                                    //info.SetValue(newObject,dr.GetValue(index),null);
                                }
                            }
                            entitys.Add(newObject);
                        }
                        dr.Close();
                    }
                }
            }
            return entitys;
        }

        public static List<T> GetList<T>(string sql, ref int totalRows, ref decimal? average) where T : new()
        {
            string connectionString = Helper.ConnectionString;
            Type businessEntityType = typeof(T);
            List<T> entitys = new List<T>();
            //Hashtable hashtable = new Hashtable();
            PropertyInfo[] properties = businessEntityType.GetProperties();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    using (SqlDataReader dr = command.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            totalRows = (int)dr["Count"];
                        }
                        dr.NextResult();
                        while (dr.Read())
                        {
                            T newObject = new T();
                            for (int index = 0; index < dr.FieldCount; index++)
                            {
                                PropertyInfo info = businessEntityType.GetProperty(dr.GetName(index)); // properties.Select(q => q.Name == dr.GetName(index)).FirstOrDefault(); // (PropertyInfo)hashtable[dr.GetName(index).ToUpper()];
                                if ((info != null) && info.CanWrite)
                                {
                                    SetValue(newObject, info, dr.GetValue(index));
                                    //info.SetValue(newObject,dr.GetValue(index).ToString());
                                    //info.SetValue(newObject,dr.GetValue(index),null);
                                }
                            }
                            entitys.Add(newObject);
                        }
                        dr.NextResult();
                        while (dr.Read())
                        {
                            average = (decimal)dr["Average"];
                        }
                        dr.Close();
                    }
                }
            }
            return entitys;
        }

        public static List<T> GetList<T>(string sql) where T : new()
        {
            string connectionString = Helper.ConnectionString;
            Type businessEntityType = typeof(T);
            List<T> entitys = new List<T>();
            //Hashtable hashtable = new Hashtable();
            PropertyInfo[] properties = businessEntityType.GetProperties();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    using (SqlDataReader dr = command.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            T newObject = new T();
                            for (int index = 0; index < dr.FieldCount; index++)
                            {
                                PropertyInfo info = businessEntityType.GetProperty(dr.GetName(index)); // properties.Select(q => q.Name == dr.GetName(index)).FirstOrDefault(); // (PropertyInfo)hashtable[dr.GetName(index).ToUpper()];
                                if ((info != null) && info.CanWrite)
                                {
                                    SetValue(newObject, info, dr.GetValue(index));
                                    //info.SetValue(newObject,dr.GetValue(index).ToString());
                                    //info.SetValue(newObject,dr.GetValue(index),null);
                                }
                            }
                            entitys.Add(newObject);
                        }
                        dr.Close();
                    }
                }
            }
            return entitys;
        }

        public static void SetValue(object inputObject, PropertyInfo propertyInfo, object propertyVal)
        {
            if ((propertyVal == DBNull.Value) == false)
            {
                Type propertyType = propertyInfo.PropertyType;
                //Convert.ChangeType does not handle conversion to nullable types
                //if the property type is nullable, we need to get the underlying type of the property
                var targetType = IsNullableType(propertyInfo.PropertyType) ? Nullable.GetUnderlyingType(propertyInfo.PropertyType) : propertyInfo.PropertyType;
                //Returns an System.Object with the specified System.Type and whose value is
                //equivalent to the specified object.
                propertyVal = Convert.ChangeType(propertyVal, targetType);
                //Set the value of the property
                propertyInfo.SetValue(inputObject, propertyVal, null);
            }
        }

        private static bool IsNullableType(Type type)
        {
            return type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>));
        }
    }

    public enum ConfigUtil
    {
        /// <summary>
        /// Data point used to make sure all the IDs start from this range. 
        /// Used for validation
        /// </summary>
        IDStartRange = 1
        //CurrentEntityID = 2
    }

    public enum ErrorType
    {
        Error = 1,
        Warning = 2,
        NotFound = 3
    }

    public class ErrorInfo
    {
        public ErrorType ErrorType = ErrorType.Error;
        /// <summary>
        /// To support serialization
        /// </summary>
        public ErrorInfo()
        {

        }
        public ErrorInfo(string propertyName, string errorMessage)
        {
            this.PropertyName = propertyName;
            this.ErrorMessage = errorMessage;
        }
        public ErrorInfo(string propertyName, string errorMessage, object onObject)
        {
            this.PropertyName = propertyName;
            this.ErrorMessage = errorMessage;
            this.Object = onObject;
        }
        public ErrorInfo(string propertyName, string errorMessage, object onObject, ErrorType errorType)
        {
            this.PropertyName = propertyName;
            this.ErrorMessage = errorMessage;
            this.Object = onObject;
            this.ErrorType = errorType;
        }

        public string ErrorMessage { get; set; }
        public object Object { get; set; }
        public string PropertyName { get; set; }
    }

    public class ValidationHelper
    {
        /// <summary>
        /// Get any errors associated with the model also investigating any rules dictated by attached Metadata buddy classes.
        /// </summary>
        /// <param name="instance"></param>
        /// <returns></returns>
        public static IEnumerable<ErrorInfo> Validate(object instance)
        {
            //return new List<ErrorInfo>();
            var metadataAttrib = instance.GetType().GetCustomAttributes(typeof(ModelMetadataTypeAttribute), true).OfType<ModelMetadataTypeAttribute>().FirstOrDefault();
            var buddyClassOrModelClass = metadataAttrib != null ? metadataAttrib.GetType() : instance.GetType();
            var buddyClassProperties = TypeDescriptor.GetProperties(buddyClassOrModelClass).Cast<PropertyDescriptor>();
            var modelClassProperties = TypeDescriptor.GetProperties(instance.GetType()).Cast<PropertyDescriptor>();

            List<ErrorInfo> errors = (from buddyProp in buddyClassProperties
                                      join modelProp in modelClassProperties on buddyProp.Name equals modelProp.Name
                                      from attribute in buddyProp.Attributes.OfType<ValidationAttribute>()
                                      where !attribute.IsValid(modelProp.GetValue(instance))
                                      select new ErrorInfo(buddyProp.Name, attribute.FormatErrorMessage(attribute.ErrorMessage), instance)).ToList();
            // Add in the class level custom attributes
            IEnumerable<ErrorInfo> classErrors = from attribute in TypeDescriptor.GetAttributes(buddyClassOrModelClass).OfType<ValidationAttribute>()
                                                 where !attribute.IsValid(instance)
                                                 select new ErrorInfo("ClassLevelCustom", attribute.FormatErrorMessage(attribute.ErrorMessage), instance);

            errors.AddRange(classErrors);
            return errors.AsEnumerable();
        }

        public static string GetErrorInfo(IEnumerable<ErrorInfo> errorInfo)
        {
            StringBuilder errors = new StringBuilder();
            if (errorInfo != null)
            {
                foreach (var err in errorInfo.ToList())
                {
                    errors.Append(err.ErrorMessage + "\n");
                }
            }
            return errors.ToString();
        }

    }


    public static class DataTypeHelper
    {

        private static string RemoveSymbols(string value)
        {
            if (string.IsNullOrEmpty(value) == false)
            {
                value = value.Replace("$", "").Replace("%", "").Replace(",", "").Replace("(", "-").Replace(")", "");
            }
            return (value == null ? "" : value);
        }

        public static float ToFloat(string value)
        {
            value = RemoveSymbols(value);
            float returnValue;
            float.TryParse(value, out returnValue);
            return returnValue;
        }

        public static decimal ToDecimal(string value)
        {
            value = RemoveSymbols(value);
            decimal returnValue;
            decimal.TryParse(value, out returnValue);
            return returnValue;
        }

        public static Int32 ToInt32(object value)
        {
            if (value == null || value == DBNull.Value) return 0;
            string v = RemoveSymbols(value.ToString());
            if (v.Contains("."))
            {
                decimal deValue = 0;
                decimal.TryParse(v, out deValue);
                return (Int32)deValue;
            }
            else
            {
                Int32 returnValue;
                Int32.TryParse(v, out returnValue);
                return returnValue;
            }
        }

        public static uint ToUInt(string value)
        {
            value = RemoveSymbols(value);
            if (value.Contains("."))
            {
                decimal deValue = 0;
                decimal.TryParse(value, out deValue);
                return (uint)deValue;
            }
            else
            {
                uint returnValue;
                uint.TryParse(value, out returnValue);
                return returnValue;
            }
        }

        public static Int32 ToInt32(string value)
        {
            value = RemoveSymbols(value);
            if (value.Contains("."))
            {
                decimal deValue = 0;
                decimal.TryParse(value, out deValue);
                return (Int32)deValue;
            }
            else
            {
                Int32 returnValue;
                Int32.TryParse(value, out returnValue);
                return returnValue;
            }
        }

        public static Int64 ToInt64(string value)
        {
            value = RemoveSymbols(value);
            if (value.Contains("."))
            {
                decimal deValue = 0;
                decimal.TryParse(value, out deValue);
                return (Int64)deValue;
            }
            else
            {
                Int64 returnValue;
                Int64.TryParse(value, out returnValue);
                return returnValue;
            }
        }

        public static Int16 ToInt16(string value)
        {
            value = RemoveSymbols(value);
            if (value.Contains("."))
            {
                decimal deValue = 0;
                decimal.TryParse(value, out deValue);
                return (Int16)deValue;
            }
            else
            {
                Int16 returnValue;
                Int16.TryParse(value, out returnValue);
                return returnValue;
            }
        }

        public static DateTime ToDateTime(string value)
        {
            DateTime returnValue;
            DateTime.TryParse(value, out returnValue);
            return returnValue.Year <= 1900 ? new DateTime(1900, 1, 1) : returnValue;
        }

        public static DateTime ToDateTime(object value)
        {
            DateTime returnValue;
            DateTime.TryParse(Convert.ToString(value), out returnValue);
            return returnValue.Year <= 1900 ? new DateTime(1900, 1, 1) : returnValue;
        }

    }
}