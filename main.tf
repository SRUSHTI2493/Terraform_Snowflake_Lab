terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.17"
    }
  }
 
  backend "remote" {
    organization = "Manchaft"
 
    workspaces {
      name = "gh-actions-demo"
    }
  }
}
 
provider "snowflake" {
}
 
resource "snowflake_database" "demo_db" {
  name    = "DEMO_DB"
  comment = "Database for Snowflake Terraform demo"
}
resource "snowflake_schema" "demo_schema" {
  database = snowflake_database.demo_db.name
  name     = "DEMO_SCHEMA"
  comment  = "Schema for Snowflake Terraform demo"
}
resource "snowflake_table" "demo_table" {
  database = snowflake_database.demo_db.name
  schema   = snowflake_schema.demo_schema.name
  name     = "DEMO_TABLE"
  comment  = "Table for Snowflake Terraform demo"
 
  column {
    name    = "column1"
    type    = "TEXT"
    comment = "Description for column1"
  }
 
  column {
    name    = "column2"
    type    = "NUMBER"
    comment = "Description for column2"
  }
}


