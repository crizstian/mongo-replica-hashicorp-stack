variable "access_key" {}
variable "secret_key" {}
variable "region" {
  description = "region to deploy the infraestructre"
  default     = "us-west-1"
}
variable "aws_account" {
  description = "specify your aws number accout"
}

variable "cluster_name" {
  default = "aero-db-cluster"
}

variable "aero_cluster_name" {
  default = "aero-cluster"
}

variable "database_private_cidr" {
  default = "10.0.3.0/24"
}

variable "bastion_cluster_name" {
  default = "aero-bastion-cluster"
}

variable "db_instance_type" {
  default = "t2.small"
}

variable "proxy_instance_type" {
  default = "t2.small"
}

variable "dbUser" {
  default = "cristian"
}
variable "dbUserPass" {
  default = "cristianPassword2017"
}
variable "dbReplicaAdmin" {
  default = "replicaAdmin"
}
variable "dbReplicaAdminPass" {
  default = "replicaAdminPassword2017"
}
variable "dbReplSetName" {
  default = "rs1"
}

variable "bastion_cidr" {
  default = "10.0.0.0/16"
}

variable "bastion_private_cidr" {
  default = "10.0.2.0/24"
}

variable "bastion_public_cidr" {
  default = "10.0.1.0/24"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster."
}