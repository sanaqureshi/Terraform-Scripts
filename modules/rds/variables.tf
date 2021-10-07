variable "region"{
type = string
}

variable "username" {
  type = string
}

variable "azs" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "identifier"{
type = string
}

variable "name"{
type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
 }

 variable "port" {
  type = number
}

variable "engine" {
 type = string
}

variable "engine_version" {
 type = string
}

variable "allocated_storage" {
 type = number
 default = 20
}

variable "maintenance_window" {
 type = string
 default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
 type = string
 default= "03:00-06:00"
}

variable "parameter_group_name"{
type = string
}
