variable "azs" {
  type    = list(string)
  default = ["us-east-2a","us-east-2b"]
}
variable "single_nat_gateway" {
  type = bool
}
