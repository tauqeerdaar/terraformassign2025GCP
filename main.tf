data "google_compute_network" "existing_vpc" {
  name  = var.vpc_name
  project = var.project_id
}

data "google_compute_subnetwork" "existing_subnet" {
  name  = var.subnet_name
  region = var.region
  project = var.project_id
}

resource "google_storage_bucket" "static-site" {
  name     = var.bucketname
  location = var.location
  project  = var.project_id
  public_access_prevention = "enforced"
  versioning {
    enabled = true
  }
  #force_destroy = true

  uniform_bucket_level_access = true

}

resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.machineType
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = var.disk_size
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.existing_subnet.name
  }
}

resource "google_sql_database_instance" "instance" {
  name             = var.sql_instance_name
  database_version = var.database_version
  region           = var.region
  
  settings {
    tier = var.db_type
    edition = "ENTERPRISE"
  }

  deletion_protection = true
}

#resource "google_sql_database" "main_database" {
#  name     = var.db_name
#  instance = google_sql_database_instance.instance.name
#  charset  = "UTF8"
#  collation = "en_US.UTF8"
#}

#resource "google_sql_database" "main_database2" {
#  name     = var.db_name2
#  instance = google_sql_database_instance.instance.name
#  charset  = "UTF8"
#  collation = "en_US.UTF8"
#}

resource "google_sql_database" "main_database"{
  for_each = toset(var.db_name)
  name = each.key
  instance = google_sql_database_instance.instance.name
  depends_on = [ google_sql_database_instance.instance ]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  #This module creates a random password
}

resource "google_sql_user" "main_user" {
  name     = var.db_username
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
  depends_on = [ random_password.password,google_sql_database_instance.instance, ]
}

resource "google_secret_manager_secret" "my_secret" {
  project   = var.project_id
  secret_id = var.secret_Name

  labels = {
    label = "my-label"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "my_secret_version" {
  secret      = google_secret_manager_secret.my_secret.id
  secret_data = random_password.password.result
  depends_on = [ google_secret_manager_secret.my_secret,random_password.password, ]
}

resource "google_compute_firewall" "postgres-rules" {
  project     = var.project_id
  name        = var.fw_rule
  network     = data.google_compute_network.existing_vpc.name
  description = "Creates firewall rule for postgres"

  allow {
    protocol  = "tcp"
    ports     = ["5432",]
  }

  source_ranges = ["0.0.0.0/0"]
}