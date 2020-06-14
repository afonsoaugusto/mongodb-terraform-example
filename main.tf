variable org_id {}

# Configure the MongoDB Atlas Provider
provider "mongodbatlas" {
  version = "v0.5.1"
}

resource "mongodbatlas_project" "project" {
  name   = "terraform-example"
  org_id = var.org_id
}

resource "mongodbatlas_cluster" "cluster_example" {
  project_id             = mongodbatlas_project.project.id
  name                   = "clusterterraform"
  num_shards             = 1
  mongo_db_major_version = "4.2"
  provider_name          = "AWS"
  //   provider_name                = "TENANT" // Using TENANT because size M2
  //   backing_provider_name        = "AWS"
  provider_instance_size_name  = "M10"
  provider_region_name         = "US_EAST_1"
  auto_scaling_disk_gb_enabled = "false"
}

resource "mongodbatlas_project_ip_whitelist" "example_ip_list" {
  project_id = mongodbatlas_project.project.id
  cidr_block = "0.0.0.0/0"
  comment    = "cidr block for tf acc testing"
}

resource "mongodbatlas_custom_db_role" "example-role" {
  project_id = mongodbatlas_project.project.id
  role_name  = "myCustomRole"

  actions {
    action = "UPDATE"
    resources {
      collection_name = ""
      database_name   = "anyDatabase"
    }
  }
  actions {
    action = "INSERT"
    resources {
      collection_name = ""
      database_name   = "anyDatabase"
    }
  }
  actions {
    action = "REMOVE"
    resources {
      collection_name = ""
      database_name   = "anyDatabase"
    }
  }
  actions {
    action = "FIND"
    resources {
      collection_name = ""
      database_name   = "anyDatabase"
    }
  }
}

resource "mongodbatlas_database_user" "example_user" {
  username           = "application-user"
  password           = "application-user-pwd"
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = mongodbatlas_custom_db_role.example-role.role_name
    database_name = "admin"
  }

  labels {
    key   = "cost-center"
    value = "engineering"
  }
}

output "project_id" {
  value = mongodbatlas_project.project.id
}

output "mongodb_version" {
  value = mongodbatlas_cluster.cluster_example.mongo_db_version
}

output "connection_strings" {
  value = mongodbatlas_cluster.cluster_example.connection_strings
}

output "state_name" {
  value = mongodbatlas_cluster.cluster_example.state_name
}