include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/"
}

inputs = {
  instance_type = "m4.large"
  instance_name = "example-server-prod"
}