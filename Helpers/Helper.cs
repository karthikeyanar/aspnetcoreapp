using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Reflection;

namespace aspnetcoreapp.Models
{
    public class SqlHelper {
        public static List<T> GetList<T>(string connectionString, string sql) where T : new() {
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
                        while(dr.Read()) {
                            T newObject = new T();
                            for(int index = 0;index < dr.FieldCount;index++) {
                                PropertyInfo info = businessEntityType.GetProperty(dr.GetName(index)); // properties.Select(q => q.Name == dr.GetName(index)).FirstOrDefault(); // (PropertyInfo)hashtable[dr.GetName(index).ToUpper()];
                                if((info != null) && info.CanWrite) {
                                    SetValue(newObject,info,dr.GetValue(index));
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

         public static void SetValue(object inputObject,PropertyInfo propertyInfo,object propertyVal) {
            if((propertyVal == DBNull.Value) == false) {
                Type propertyType = propertyInfo.PropertyType;
                //Convert.ChangeType does not handle conversion to nullable types
                //if the property type is nullable, we need to get the underlying type of the property
                var targetType = IsNullableType(propertyInfo.PropertyType) ? Nullable.GetUnderlyingType(propertyInfo.PropertyType) : propertyInfo.PropertyType;
                //Returns an System.Object with the specified System.Type and whose value is
                //equivalent to the specified object.
                propertyVal = Convert.ChangeType(propertyVal,targetType);
                //Set the value of the property
                propertyInfo.SetValue(inputObject,propertyVal,null);
            }
        }

         private static bool IsNullableType(Type type) {
            return type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>));
        }
    }
}