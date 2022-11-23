package model

var TFValues = ReadJson("values.json")
var PROJECT_ID = TFValues["PROJECT_ID"]
var SQL_CONNECTION_NAME = TFValues["sql_connection_name"]
var SQL_DATABASE = TFValues["sql_database"]
var SQL_ENDPOINT = TFValues["sql_private_ip"]
var SQL_ROOT_PASSWORD = TFValues["sql_root_password"]
var SQL_USER = TFValues["sql_user"]
var SQL_USER_PASSWORD = TFValues["sql_user_password"]
var PUBSUB_TOPIC = TFValues["pubsub_topic"]
var PUBSUB_SUBSCRIPTION = TFValues["pubsub_subscription"]
var BACKEND_FQDN = GetEnv("BACKEND_FQDN", "localhost")
var BACKEND_SCHEMA = GetEnv("BACKEND_SCHEMA", "http")
var BACKEND_TOKEN = GetEnv("BACKEND_TOKEN", "bWE3ZU0zZXBoYWVzaXVob28yWm9CMnVhNHNodXBhMWIK")
