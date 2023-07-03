resource "random_password" "db_master" {
  length  = 10
  special = false
}

resource "random_string" "db_user" {
  length      = 16
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}