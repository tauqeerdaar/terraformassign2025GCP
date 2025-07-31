variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}

#variable "bucket_backend" {
 # type    = string
  #default = "terrabackend"
#}

variable "bucketname" {
  type    = string
}

#variable "bucket_backend_prefix" {
 # type    = string
  #default = "terraform/state"
#}

variable "vpc_name" {
  type    = string
  default = "default"
}

variable "subnet_name" {
  type    = string
  default = "default"
}

variable "location" {
  type    = string
  default = "us"
}

variable "machineType" {
  type    = string
}

variable "vm_name" {
  type    = string
}

variable "disk_size" {
  type  = number
  default = 20
}

variable "sql_instance_name" {
  type    = string
}

variable "database_version" {
  type    = string
  default = "POSTGRES_17"
}

variable "db_type" {
  type    = string
}

#variable "db_name" {
#  type    = string
#}

#variable "db_name2" {
#  type    = string
#}

variable "db_name" {
    type = list(string)

}

variable "db_username" {
  type    = string
}

variable "secret_Name" {
  type    = string
}

variable "fw_rule" {
  type    = string
}